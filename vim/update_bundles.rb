#!/usr/bin/env ruby

git_bundles = [ 
  "git://github.com/msanders/snipmate.vim.git",
  "git://github.com/thogg4/only-primary-nerdtree.git",
  "git://github.com/tpope/vim-markdown.git",
  "git://github.com/tpope/vim-rails.git",
  "git://github.com/vim-ruby/vim-ruby.git",
  "git://github.com/mileszs/ack.vim.git",
  "git://github.com/scrooloose/nerdcommenter.git",
  "git://github.com/kchmck/vim-coffee-script.git",
  "git://github.com/altercation/vim-colors-solarized.git",
  "git://github.com/pangloss/vim-javascript.git",
  "git@github.com:slim-template/vim-slim.git",
  "git://github.com/groenewege/vim-less.git",
  "git://github.com/juvenn/mustache.vim.git",
  "git://github.com/flazz/vim-colorschemes.git",
  "git@github.com:vim-airline/vim-airline.git"
]

vim_org_scripts = [
]

zip_files = { }

require 'fileutils'
require 'open-uri'

bundles_dir = File.join(File.dirname(__FILE__), "bundle")

FileUtils.cd(bundles_dir)

puts "Trashing everything (lookout!)"
Dir["*"].each {|d| FileUtils.rm_rf d }

git_bundles.each do |url|
  dir = url.split('/').last.sub(/\.git$/, '')
  puts "  Unpacking #{url} into #{dir}"
  `git clone #{url} #{dir}`
  FileUtils.rm_rf(File.join(dir, ".git"))
end

zip_files.each do |name, url|
  puts "  Downloading zip #{name}"
  local_file = "#{name}.zip"
  FileUtils.mkdir_p(name)
  File.open(local_file, "w") do |file|
    file << open(url).read
  end
  `unzip #{local_file} -d #{name}`
  FileUtils.rm(local_file)
end

vim_org_scripts.each do |name, script_id, script_type|
  puts "  Downloading #{name}"
  local_file = File.join(name, script_type, "#{name}.vim")
  FileUtils.mkdir_p(File.dirname(local_file))
  File.open(local_file, "w") do |file|
    file << open("http://www.vim.org/scripts/download_script.php?src_id=#{script_id}").read
  end
end
