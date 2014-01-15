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
	return [] unless str[/[^\^\$]+/]

	#puts "before: #{str}"
	prefixed = str[/^\^/]
	suffixed = str[/\$$/]
	str = str[/(?=\^).+/] if prefixed
	str = str[/.+(?=\$)/] if suffixed
	#puts "after: #{str}"


	0.upto(str.length).reduce([]) do |arr, n|
		(0..(str.length-1)).to_a.combination(n).each do |combo|
			spl = str.split(//).map{|ch| ch[/[^\w\s]/] ? "\\"+ch : ch}
			combo.each{ |k| spl[k] = '.' }
			arr << "#{'^' if prefixed}#{spl.join}#{'$' if suffixed}"
		end
		arr
	end
end

def golf a, b
	poss = []
	a.each do |ai|
		ai = regexify(ai)
		parts = subparts(ai)
		parts.each do |part|
			dots = dotify(part)
			poss += dots.reject{ |dot| b.any?{|bi| bi[/#{dot}/]} }
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
		(fin.count ==0 ? "No Solution" : "#{'^' unless success}(#{fin.join('|')})#{'$' unless success}")
end

def getLists
	words = File.open('./app/controllers/unix_words.txt','r').readlines.map(&:chomp)
		.select{|w| (5..10).include?(w.length) }
		.sample(40).shuffle
	res = [words[0..19],words[20..39]]
	reg = golf *res
	[*res, score(reg, *res)[2], reg]
end

def score reg, m=session[:match], r=session[:reject]
	return [[],[],0] if reg.nil? or reg == ''

	match_res, reject_res = m.grep(/#{reg}/), r.grep(/#{reg}/)
	score = match_res.count * 10 - reject_res.count * 10 - reg.length

	[match_res, reject_res, score]
rescue
	[[],[],0]
end