let project = new Project('Impact');

project.windowOptions.width = 640;
project.windowOptions.height = 480;
project.addAssets('Assets/**');
project.addSources('Sources');

resolve(project);
