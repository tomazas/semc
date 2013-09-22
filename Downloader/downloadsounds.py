#!/usr/bin/env python3
"""
Sound downloader

TODO: needs same checks for wavfile file, currently assumes that file sample type is int16
TODO: implement increment update
"""
from __future__ import print_function

import sys;
import yaml;

import pprint;
import logging;

import os;
import distutils.spawn;
import scipy.io.wavfile;

import numpy;

import h5py;

import uuid;

import tempfile;

import argparse;

def process_input(data,h5group):
  """
  @return meta stream information in array of tuples : (hdf_path,samplerate,samplename,objref)
  """
  logging.info("Processing input");
  data = data['input'];

  ffmpeg_cmd="ffmpeg";

  rnd = "%s" % uuid.uuid4();
  if distutils.spawn.find_executable("avconv") is not None:
    ffmpeg_cmd = 'avconv'


  ret = [];

  for i in data:
    logging.info("Downloading `%s'" % i['name']);
    downloaded = False;
    inp_name = "/tmp/%(uuid)s-out_download_sounds.wav" % {'uuid' : rnd};
    inp_unlink = False;
    if i['name'] in h5group:
        logging.info("Skipping download because data exists")
        ds = h5group[ i['name'] ];
        continue;
    elif 'youtube' in i:
        logging.debug("Downloading with youtube downloader url: %s" % i['youtube'])
        os.system("youtube-dl -x -o /tmp/%(uuid)s-out_download_sounds.data --audio-format wav '%(url)s'" % {'uuid' : rnd,'url' : i['youtube'] });
        inp_unlink = True;
    elif 'file' in i:
        inp_unlink = False;
        inp_name = i['file']
    else:
       logging.warning("Unknown media type")
       continue;


    ffmpeg_cp= "%(ffmpeg)s -i %(inp_n)s" % {'ffmpeg' : ffmpeg_cmd,'inp_n' : inp_name};
    if 'start' in i:
       ffmpeg_cp = ffmpeg_cp +" -ss %(start)s" % {'start' : i['start']};
    if 'len' in i:
       ffmpeg_cp = ffmpeg_cp +" -t %(len)s" % {'len' : i['len']}


    ffmpeg_cp= ffmpeg_cp+" /tmp/%(uuid)s-cut_out_download_sounds.wav" % { 'uuid':rnd }; # slice sample

    os.system(ffmpeg_cp); # slice sample

    if inp_unlink:
       os.unlink(inp_name);

    f = scipy.io.wavfile.read("/tmp/%(uuid)s-cut_out_download_sounds.wav" % {'uuid' : rnd });

    fn = numpy.array(f[1]);
    ds = h5group.create_dataset(i['name'],shape = f[1].shape,dtype=fn.dtype,data=fn);
    sample_rate = ds.attrs['sample_rate'] = f[0];
    del f;
    os.unlink("/tmp/%(uuid)s-cut_out_download_sounds.wav" % {'uuid' : rnd })
    ret.append( (ds.name,sample_rate,i['name'],ds.ref)  )
  return ret;

def write_proceesed_data(prdata,grp):

  str_type = h5py.new_vlen(str);
  #(hdf_path,samplerate,samplename,objref)
  meta_info = numpy.dtype([ 
	('Path',str_type),
	('SampleRate',numpy.int),
	('SampleName',str_type),
	('objref',h5py.h5t.special_dtype(ref=h5py.Reference))]);

  if not 'raw_sample_info' in grp: # simple case
    grp.create_dataset("raw_sample_info",(len(prdata),),meta_info,numpy.array(prdata,dtype=meta_info),chunks = True,maxshape=None);

  pass;

def make_long_name(codec,bitrate,param,channels,name):
  return "%(codec)s-%(bitrate)s-%(param)s-%(channels)s___%(name)s" % {
    'codec' : codec,
    'bitrate' : bitrate,
    'param' : param,
    'channels' : channels,
    'name' : name,
  }

def write_fobj(fid, rate, data):
    import struct;
    """
    Write a numpy array as a WAV file
    THIS IS QUICK FIX TO SUPPORT TEMPORARY FILES
    Parameters
    ----------
    filename : file
        The name of the file to write (will be over-written).
    rate : int
        The sample rate (in samples/sec).
    data : ndarray
        A 1-D or 2-D numpy array of integer data-type.

    Notes
    -----
    * Writes a simple uncompressed WAV file.
    * The bits-per-sample will be determined by the data-type.
    * To write multiple-channels, use a 2-D array of shape
      (Nsamples, Nchannels).

    """

    fid.write(b'RIFF')
    fid.write(b'\x00\x00\x00\x00')
    fid.write(b'WAVE')
    # fmt chunk
    fid.write(b'fmt ')
    if data.ndim == 1:
        noc = 1
    else:
        noc = data.shape[1]
    bits = data.dtype.itemsize * 8
    sbytes = rate*(bits // 8)*noc
    ba = noc * (bits // 8)
    fid.write(struct.pack('<ihHIIHH', 16, 1, noc, rate, sbytes, ba, bits))
    # data chunk
    fid.write(b'data')
    fid.write(struct.pack('<i', data.nbytes))
    import sys
    if data.dtype.byteorder == '>' or (data.dtype.byteorder == '=' and sys.byteorder == 'big'):
        data = data.byteswap()
    try:
      data.tofile(fid)
    except Exception as err:
      # Python ver <3.0 specific error here
      logging.error('Are you sure you`re using Python 3? Error occured.')
      raise err
    # Determine file size and place it in correct
    #  position at start of the file.
    size = fid.tell()
    fid.seek(4)
    fid.write(struct.pack('<i', size-8))




def transcode(inp,h5f,data_grp,meta_grp):
  logging.info("Starting transcoding");


  ffmpeg_cmd="ffmpeg";
  if distutils.spawn.find_executable("avconv") is not None:
    ffmpeg_cmd = 'avconv'

  records = [];

  for sample in inp['input']:
    #Write Sample
    sample_f = tempfile.NamedTemporaryFile(suffix='.wav');
    try:
      s = h5f['/raw/%s' % sample['name']];
    except:
      logging.error("Sample %s not found" % sample['name']);
      continue;
    write_fobj(sample_f,s.attrs['sample_rate'],numpy.array(s))
    sample_f.flush();

    for prm in inp['output']:
      if not 'ffmpeg_params' in prm:
        ffmpeg_params = [''];
        ffmpeg_config_names = ['None'];
      else:
        ffmpeg_params = prm['ffmpeg_params'];
        ffmpeg_config_names = prm['ffmpeg_config_names'];

      ffmpeg_plen = len(ffmpeg_params);

      for param_i in range(ffmpeg_plen):
        for bitrate in prm['bitrates']:
          long_name = make_long_name(prm['name'],bitrate,ffmpeg_config_names[param_i],prm['channels'],sample['name']);
          logging.info("Transcoding %s" % long_name); 
          if long_name in data_grp:
            logging.info("Sample already encoded skipping");
            continue;

          rnd = uuid.uuid4();
          enc_prt = "/tmp/%s-%s.%s" % (rnd,long_name,prm['ext']);
          dec_prt = "/tmp/%s-%s.dec.wav" %(rnd,long_name);

          enc_cmd= "%(ffmpeg)s -i %(inp)s -strict experimental -acodec %(codec)s -b %(bitrate)dk %(params)s %(out)s" % { 'ffmpeg' : ffmpeg_cmd,'inp' : sample_f.name,'codec' : prm['acodec'],'bitrate' : bitrate,'params' : ffmpeg_params[param_i],'out' : enc_prt}
          logging.info("Encoding command %s" % enc_cmd);
          os.system(enc_cmd)
          os.system("%(ffmpeg)s -i %(inp)s %(out)s" % {'ffmpeg' : ffmpeg_cmd,'inp' : enc_prt,'out' : dec_prt})

          f = scipy.io.wavfile.read("%s" % dec_prt);

          fn = numpy.array(f[1]);
          ds = data_grp.create_dataset(long_name,shape = f[1].shape,dtype=fn.dtype,data=fn);
          sample_rate = ds.attrs['sample_rate'] = f[0];

          os.unlink(enc_prt);
          os.unlink(dec_prt);
          records.append( (ds.name,long_name,sample['name'],prm['name'],bitrate,ffmpeg_config_names[param_i],ds.ref) )

  if len(records)  > 0:
    str_type = h5py.new_vlen(str);
    meta_info = numpy.dtype([('Path',str_type),('LongName',str_type),('SampleName',str_type),('Codec',str_type),('Bitrate','i'),('Param',str_type),('Ref',h5py.h5t.special_dtype(ref=h5py.Reference))]);
    meta_grp.create_dataset('encoded_samples',(len(records),),meta_info,numpy.array(records,dtype=meta_info));
  pass;


def main():

    parser = argparse.ArgumentParser();

    parser.add_argument("-i","--input",help="input file, default formats.yml",default="formats.yml")
    parser.add_argument("-o","--output",help="output file, default samples.hdf5",default="samples.hdf5")
    args = parser.parse_args();

    logging.basicConfig(filename='debug.log', format='%(asctime)-15s %(message)s')
    logging.getLogger().setLevel(logging.DEBUG)
    data = yaml.load(open(args.input));
    pprint.pprint(data);
    h5file = h5py.File(args.output,"a");
    if not 'info' in h5file.attrs : h5file.attrs['info'] = 'Audio samples file';


    if not '/info' in h5file:
       info = h5file.create_group("/info");
    else:
       info = h5file['/info']

    if not '/raw' in h5file:
      grp = h5file.create_group("/raw");
    else:
      grp = h5file['/raw'];


    if not '/enc' in h5file:
       enc = h5file.create_group("/enc");
    else:
       enc = h5file['/enc'];

    samples = process_input(data,grp);
    write_proceesed_data(samples,info)
    transcode(data,h5file,enc,info);
    return;

if __name__ == '__main__':
    main();

