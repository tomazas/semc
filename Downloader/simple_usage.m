% warning there are no filter from diferent samples...
m = h5read('samples.hdf5','/raw/AudioSample1'); %magic API
m_samplerate = h5readatt('samples.hdf5','/raw/AudioSample1','sample_rate') %magic too


sample_list = h5read('samples.hdf5','/info/encoded_samples') % (something like readAllSampleAudioFiles)



l = length(sample_list.Path); % matlab bug?

l=4; % use only first 4

m = m(1,:)'; % there getting orginal sample
m = double(m) / 32676.0;

energies = [];
[ref_tm ref_energy] = fftEnergy(m,512,256,double(m_samplerate),1);
for i = 1:l

  s = h5read('samples.hdf5',sample_list.Path{i}); % reading sampledate

  disp(sprintf('Calculating %s',sample_list.Path{i}));
  
  s = s(1,:)';
  
  s = double(s) / 32676.0; % normalize, from int16 to float
  [tm e ] = fftEnergy(s,512,256,double(m_samplerate),1); % using function
  
  energies(i,:) = e - ref_energy;
  
 
end

size(energies)
plot(tm,energies)
title 'Diference spectral energy from orginal in DB';
ylabel 'Diference, DB';
xlabel 'Time, s';
legend(sample_list.Path{1:l});

