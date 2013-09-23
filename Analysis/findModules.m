function modules = findModules()

  global SEMC;
    
  listing = dir(strcat(SEMC.MODULES_DIR,'/*.m'));

  modules =  {};
  
  for i = 1:length(listing)
      modules{i} = listing(i).name(1:end-2);
  end
  
  
end
