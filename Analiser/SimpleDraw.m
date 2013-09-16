% fftEnergy test
% draw simple spectral energy plot
%needs samples.hdf5 to work, https://mega.co.nz/#!VVkTzC7D!IdxhZTcBsLaSkC4tGu2_GAN66SEP_PyIjKBSAlTEdUU

m = h5read('samples.hdf5','/raw/AudioSample1');  %magic API
m_samplerate = h5readatt('samples.hdf5','/raw/AudioSample1','sample_rate') %magic too 


sample_list = h5read('samples.hdf5','/info/encoded_samples') % (something like readAllSampleAudioFiles)



l = length(sample_list.Path); % matlab bug?

l=4; % use only first 4

m = m(1,:)';
m = double(m) / 32676.0;

energies = [];
[ref_tm ref_energy] = fftEnergy(m,512,256,double(m_samplerate),1);
for i = 1:l

  s = h5read('samples.hdf5',sample_list.Path{i});

  disp(sprintf('Calculating %s',sample_list.Path{i}));
  
  s = s(1,:)';
  
  s = double(s) / 32676.0; % normalize
  [tm e ] = fftEnergy(s,512,256,double(m_samplerate),1);
  
  energies(i,:) = e - ref_energy;
  
 
end

size(energies)
plot(tm,energies)
title 'Diference spectral energy from orginal in DB';
ylabel 'Diference, DB';
xlabel 'Time, s';
legend(sample_list.Path{1:l});