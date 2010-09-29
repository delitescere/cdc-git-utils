class Contract < Thor
  desc "submit PATH MESSAGE", "submit the contract at the given path"
  def submit(path, message)
    Dir.chdir(path) do
      staged_count = %x{ git add --verbose -A | wc -l }.chomp.to_i
      if staged_count == 0
        puts "No changes to contract in #{path}"
      else
        %x{ git commit -m #{message.inspect} }
        %x{ git push origin master }
        puts "\nSubmitted contract revision #{revision('.')} for #{path.split('/').last}"
      end
    end
  end

  desc "review PATH", "review the contract at the given path"
  def review(path)
    Dir.chdir(path) do
      if %x{git pull 2>/dev/null} =~ /up to date.$/m
        puts "Contract at #{path} is up to date."
      else
        puts "Contract revision #{revision('.')} at #{path} is ready to review."
      end
    end
  end

  desc "sign PATH", "sign the contract at the given path"
  def sign(path)
    git_status = `git status --short`.split("\n").collect {|l| l.strip}
    remainder = git_status.reject{|l| l == "M #{path.sub(/\/$/,'')}"}
    unless remainder.empty?
      puts "Unable to sign contract with dirty working directory"
      return
    end
    if git_status.empty?
      puts "Contract at #{path} does not appear to have changed"
    else
      message = "Signed contract revision #{revision(path)} for #{path.split('/').last}"
      puts message
      `git add #{path}`
      `git commit -m #{message.inspect}`
    end
  end

  private 

    def revision(path)
      Dir.chdir(path) { %x{git rev-parse --short HEAD}.chomp }
    end
end
