# spree_theme

# generate key word list by db/seeds/*.yml

#require ''

EMBEDDED_PATTERN = /<%(=+|\#)?(.*?)-?%>/m
arr = []
Dir['./db/seeds/*.yml'].each{|file|
  open(file).each_line{|line|
    if line=~EMBEDDED_PATTERN
      next if $1=='#'
      arr << $2.strip
    end
  }
}

arr.uniq!

partial_tags = arr.select{|line| line =~/partial/}
variable_tags = arr.select{|line| line =~/^@/}
else_tags = arr - partial_tags -variable_tags
open('doc/theme_tags.txt','w') do|f|
  f.puts( partial_tags.sort.join("\n") )
  f.puts( variable_tags.sort.join("\n") )
  f.puts( else_tags.sort.join("\n") )
end
