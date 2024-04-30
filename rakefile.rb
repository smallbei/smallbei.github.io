require 'rake'
require 'yaml'

SOURCE = "."
CONFIG = {
  'posts' => File.join(SOURCE, "_posts"),
  # 'drafts' => File.join(SOURCE, "_drafts"),
  'post_ext' => "md",
}

# Usage: rake post title="A Title"
desc "Begin a new post in #{CONFIG['posts']}"
task :post do
  abort("rake aborted: '#{CONFIG['posts']}' directory not found.") unless FileTest.directory?(CONFIG['posts'])
  title = ENV["title"] || "new-post"
  tag_input = ENV["tag"] || "" # 获取标签参数，如果没有指定则为空字符串
  tags = tag_input.split(',').map(&:strip).reject(&:empty?) # 使用正则表达式分割字符串，并去除空字符串和过滤空元素
  slug = title.downcase.strip.gsub(' ', '-')
  filename = File.join(CONFIG['posts'], "#{Time.now.strftime('%Y-%m-%d')}-#{slug}.#{CONFIG['post_ext']}")

  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end

  puts "Creating new post: #{filename}"

  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/-/,' ')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d')}"
    if tags.any? # 如果有标签，写入tags字段
      post.puts "tags: \"#{tags.join(' ')}\"" # 使用空格而不是逗号来连接标签
    end
    post.puts "category: "
    post.puts "---"
    post.puts "" # 添加一个空行，以便YAML头信息和文章内容之间有所区分
  end
end