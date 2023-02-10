desc 'run all pre-commit hooks against all files'
task :check do
  sh 'pre-commit run --all-files'
end

desc 'install the pre-commit hooks'
task :checkinstall do
  sh 'pre-commit install'
end

desc 'check the pre-commit hooks for updates'
task :checkupdate do
  sh 'pre-commit autoupdate'
end
