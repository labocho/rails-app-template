namespace :assets do
  task :precompile => :vite
  task :vite do
    sh "yarn", "install"
    sh "yarn", "build"
  end
end
