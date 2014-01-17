def regexify str
	"^#{str}$"
end

def subparts str
	1.upto([str.length, 5].min).reduce([]) do |arr, n|
		arr << str.split(//).each_cons(n).to_a.map(&:join)
		arr
	end.flatten.uniq
end

def matches regex, array
	array.grep(/#{regex}/)
end

def dotify str
	return [] unless str[/\w+/]

	prefixed = str[/\^/]
	suffixed = str[/\$/]
	str = str[/\w+/] if prefixed
	str = str[/\w+/] if suffixed


	0.upto(str.length).reduce([]) do |arr, n|
		(0..(str.length-1)).to_a.combination(n).each do |combo|
			spl = str.split(//)
			combo.each{ |k| spl[k] = '.' }
			arr << "#{'^' if prefixed}#{spl.join}#{'$' if suffixed}"
		end
		arr
	end
end

def inbetweenify str
	return [] unless str[/\w+/]

	arr = []
	0.upto(str.length-2).each do |n|
		(n+1).upto(str.length-1).each do |k|
			arr << "#{str[n]}.*#{str[k]}"
		end
	end
	arr.uniq
end

def golf a, b
	poss = []
	a.each do |ai|
		parts = subparts(regexify(ai))
		parts.each do |part|
			dots = dotify(part)
			bets = inbetweenify(part)
			poss += dots.reject{ |dot| b.any?{|bi| bi[/#{dot}/]} }
			poss += bets.reject{ |bet| b.any?{|bi| bi[/#{bet}/]} }
		end
	end

	poss.sort!{|a,b| a.length<=>b.length}

	fin = []
	last_length = a.length
	temp = a
	loop do
		max = poss.max_by{|fi| temp.count{|ai| ai[/#{fi}/]} }
		fin << max
		temp = temp.reject{|ai| ai[/#{max}/]}
		break if temp.empty? or temp.length == last_length
		last_length = temp.length
	end
	success = true
	if(temp.length == last_length)
		puts "Partial solution"
		fin = a.reject{|oi| b.any?{|bi| bi[/^#{oi}$/]} }
		success = false
	end

	fin.count == 1 ? fin.join : 
		(fin.count ==0 ? "No Solution" : "#{'^(' unless success}#{fin.join('|')}#{')$' unless success}")
end

def getLists
	words = File.open('./app/controllers/unix_words.txt','r').readlines.map(&:chomp)
	wd = dotify(words.select{|w|(3..5).include?(w.length)}
		.sample(1)[0]).grep(/[\w]*[.]+[\w.]+/).sample(1)[0]
	words = words.select{|w| (5..10).include?(w.length) }

	lets = (('A'..'Z').to_a - %w{A E I O U A Z V X W Q K J}).sample(4+rand(4)) + %w{A E I O U}.sample(1 + rand(2))
	chrs = (('A'..'Z').to_a - %w{J X Z Q A E I O U}).sample(1) + %w{A E I O U}.sample(1)
	regs = [/(#{chrs[0]})#{chrs[1]}\1/, /(#{chrs[0]}).*\1/, /^${chrs[0]}.+#{chrs[0]}$/, 
			/#{chrs[0]}.{3,}#{chrs[1]}/, /(\w)\1$/, /(\w).\1.\1/,
			/(\w)(\w).*\1\2/, /[#{lets.join}]+/,/^[#{lets.join}]{2}/, /^#{chrs[1]}.+#{chrs[0]}$/, /#{wd}/, //]
	regex = regs.sample(1)[0]

	matches = words.select{|w| w[regex]}.shuffle.sample(15).sort
	rejects = words.reject{|w| regex == // ? matches.include?(w) : w[regex]}.shuffle.sample(15).sort

	(matches.length <=5 || rejects.length <=5) ? getLists : [matches, rejects]
end

def score reg, m=session[:match], r=session[:reject]
	return [[],[],m.count] if reg.nil? or reg == ''

	match_res, reject_res = m.grep(/#{reg}/), r.grep(/#{reg}/)
	score = match_res.count - reject_res.count- reg.length

	[match_res, reject_res, m.count - score - (reject_res.count==0 ? 5 : 0)]
rescue
	[[],[],m.count]
end