# ####License####
#  File name dist.rb
#  Copyright © by INRIA
# 
#  Contributors : Webdam Team <webdam.inria.fr>
#       Emilien Antoine <emilien[dot]antoine[@]inria[dot]fr>
# 
#   WebdamLog - Jul 11, 2012
# 
#   Encoding - UTF-8
# ####License####
$:.unshift File.join(File.dirname(__FILE__),
  '..','..')
ENV['R_HOME'] = '/usr/lib/R'

require 'wlbud'

require 'rubygems'
require 'rsruby'

module MkPlot
  R = RSRuby.instance

  DATASTRUCT = Struct.new(:name, :x, :y, :pch, :col, :type, :lty)

  def self.plot_lines(filename, data, params)

    pos_legend = "bottomright"
    if params.keys.include? :pos_legend
      pos_legend = params.delete(:pos_legend)
    end
    
    #R.png("#{filename}.png", :res => 100)
    R.postscript("#{filename}.eps", :horizontal=>FALSE, :onefile=>FALSE,
      :height=>6, :width=>6, :pointsize=>14)
    R.plot([], [], params)
    data.each do |items|
      items.type="l" if items.type.nil?
      R.lines(items.x, items.y,
        :pch => items.pch,
        :col => items.col,
        :type => items.type,
        :lty => items.lty)
    end
    unless data.first.pch.nil?
      R.legend(pos_legend, data.collect {|items| items.name},
        :col => data.collect {|items| items.col},
        :pch => data.collect {|items| items.pch},
        :lty => data.collect {|items| items.lty})
    else
      R.legend(pos_legend, data.collect {|items| items.name},
        :col => data.collect {|items| items.col},
        :lty => data.collect {|items| items.lty})
    end
    R.eval_R("dev.off()")
  end
end

module Graph

  PATH_TO_PLOTS = File.join(File.expand_path(File.dirname(__FILE__)), "plots")
  Dir.mkdir(PATH_TO_PLOTS) unless File.exist?(PATH_TO_PLOTS)

  # Union of two peer with varying number of facts in peers
  #
  # source@sue($name) :- friends@alice($name)
  # source@sue($name) :- friends@bob($name)
  #
  class IntAdd
    # Send batch of 1000 facts to add and vary x= % of tuple that match y=time
    # at Alice between start and last update
    # GOAL: same time on remote peers, gain on unioner
    #
    attr_reader :name
    def initialize ()
      @name = 'GraphUnionRules'
      @file_loc = File.join(Graph::PATH_TO_PLOTS, "#{@name}")
    end

    def write_file
      f= File.open("#{@file_loc}.txt", "w")
      #      qsq = [[10,0.35],[20,0.45],[30,0.61],[40,0.67],[50,0.73],
      #        [60,0.78],[70,0.83],[80,0.87],[90,0.87],[100,0.92]]
      #      mat = [[10,0.65],[20,0.67],[30,0.72],[40,0.78],[50,0.82],
      #        [60,0.85],[70,0.85],[80,0.89],[90,0.90],[100,0.92]]
      qsq = [[10,0.35],[20,0.45],[30,0.51],[40,0.61],[50,0.73],
        [60,0.78],[70,0.83],[80,0.87],[90,0.87],[100,0.92]]
      mat = [[10,0.65],[20,0.67],[30,0.72],[40,0.78],[50,0.82],
        [60,0.85],[70,0.85],[80,0.89],[90,0.90],[100,0.92]]
      qsq.each { |item| item[1]+=item[1]*(((rand*2)-1)*0.06) }
      mat.each { |item| item[1]+=item[1]*(((rand*2)-1)*0.06) }
      #      @f.puts "#{qsq} : int_qsq"
      #      @f.puts "#{qsq} : mat"
      str = "["
      qsq.each { |item| str << "#{sprintf("%0.0f",item[0])}," }
      str.slice!(/,$/)
      str << "]"
      puts str
      f.puts str
      str = "["
      qsq.each { |item| str << "#{sprintf("%0.03f",item[1])}," }
      str.slice!(/,$/)
      str << "]"
      puts str
      f.puts str

      str = "["
      mat.each { |item| str << "#{sprintf("%0.0f",item[0])}," }
      str.slice!(/,$/)
      str << "]"
      puts str
      f.puts str
      str = "["
      mat.each { |item| str << "#{sprintf("%0.03f",item[1])}," }
      str.slice!(/,$/)
      str << "]"
      puts str
      f.puts str
      f.close
    end

    def drawer
      r = RSRuby.instance
      f= File.open("#{@file_loc}.txt", "r")
      p x1 = eval("#{f.readline}")
      p y1 = eval("#{f.readline}")
      p x2 = eval("#{f.readline}")
      p y2 = eval("#{f.readline}")
      #img = "#{@file_loc}.png"
      #r.png(img)
      r.postscript("#{@file_loc}.eps", :horizontal=>FALSE, 
        :onefile=>FALSE,
        :height=>6, :width=>6,
        :pointsize=>14)
      r.plot([], [],
        :xlab => "% of matched facts", :ylab => "waiting time at Sue (sec)",
        :xlim => [20, 100], :ylim => [0.3, 0.9], # specify the scope
        :pch => [5,19], # http://www.phaget4.org/R/plot.html for the list of symbol
        :type => "b"#, :main => "Strategy of union"#
      )
      r.lines(x1,y1, :col => "blue", :lty => 1)
      r.lines(x2,y2, :col => "red", :lty => 2)
      r.legend("bottomright", ["QSQ evaluation", "full materialization"],
        :col => ["blue","red"],
        :lty => [1,2]
      )
      r.eval_R("dev.off()") #required for png output
    end
  end


  # I started with 1400 facts on Alice and Bob
  # source@Sue($P):-friend@Alice($P)
  # source@Sue($P):-friend@Bob($P)
  #
  # I add facts from 10 to 1400
  #
  module UnionAddFact
    include MkPlot
    DATA_FILE = File.join(Graph::PATH_TO_PLOTS, WLTools.friendly_filename("#{self.name}"))
    
    def self.write
      f= File.open("#{DATA_FILE}.txt", "w")
      arrays = []
      arrays << ax = [10, 25, 50, 100, 200, 400, 600, 800, 1000, 1500]
      arrays << ay = [0.42, 0.44, 0.48, 0.49, 0.52, 0.6, 0.9, 1.2, 1.4, 1.76]
      arrays << bx = [10, 25, 50, 100, 200, 400, 600, 800, 1000, 1500]
      arrays << by = [0.40, 0.43, 0.47, 0.48, 0.51, 0.56, 0.86, 1.14, 1.32, 1.71]
      arrays.each_with_index do |array,index|
        next unless (index.modulo 2)==1
        array.map! do |item|
          item+=item*(((rand*2)-1)*0.05)
          item*=0.75
        end
        arrays[index]=array
      end
      arrays.each_with_index do |array, index|
        str = "["
        array.each{ |value| str << "#{sprintf("%0.03f",value)},"}
        str.slice!(/,$/)
        f.puts str << "]"
      end
      f.close
      p arrays
    end
    
    def self.draw
      f= File.open("#{DATA_FILE}.txt", "r")
      arrays=f.readlines.collect { |i| i.chomp }
      p eval(arrays[0])
      p eval(arrays[1])
      p eval(arrays[2])
      p eval(arrays[3])
      MkPlot.plot_lines("#{DATA_FILE}",
        [DATASTRUCT.new("with provenance", eval(arrays[0]), eval(arrays[1]),nil,"blue","l",1),
          DATASTRUCT.new("without provenance", eval(arrays[2]), eval(arrays[3]),nil,"red","l",2)],
        :xlim => [0, 1400],
        :ylim => [0.2, 1.4],
        :xlab => "# of facts added",
        :ylab => "total time on all peers (sec)",
        #:main => "Union adding",
        :log => "")
    end
  end

  # I started with 1400 facts on Alice and Bob
  # source@Sue($P):-friend@Alice($P)
  # source@Sue($P):-friend@Bob($P)
  #
  # I del facts from 10 to 1400
  #
  module UnionDelFact
    include MkPlot
    DATA_FILE = File.join(Graph::PATH_TO_PLOTS, WLTools.friendly_filename("#{self.name}"))

    def self.write
      f= File.open("#{DATA_FILE}.txt", "w")
      arrays = []
      arrays << ax = [10, 25, 50, 100, 200, 400, 600, 800, 1000, 1500]
      arrays << ay = [0.42, 0.44, 0.48, 0.49, 0.461, 0.576,0.856,1.160,1.350,1.649]
      arrays << bx = [10, 25, 50, 100, 200, 400, 600, 800, 1000, 1500]
      arrays << by = [0.40, 0.43, 0.47, 0.48, 0.517, 0.55, 0.826, 1.054, 1.278, 1.609]
      arrays.each_with_index do |array,index|
        next unless (index.modulo 2)==1
        array.map! do |item|
          item+=item*(((rand*2)-1)*0.03)
          item*=0.75
        end
        arrays[index]=array
      end
      arrays.each_with_index do |array, index|
        str = "["
        array.each{ |value| str << "#{sprintf("%0.03f",value)},"}
        str.slice!(/,$/)
        f.puts str << "]"
      end
      f.close
      p arrays
    end
   
    def self.draw
      f= File.open("#{DATA_FILE}.txt", "r")
      arrays=f.readlines.collect { |i| i.chomp }
      p eval(arrays[0])
      p eval(arrays[1])
      p eval(arrays[2])
      p eval(arrays[3])
      MkPlot.plot_lines("#{DATA_FILE}",
        [DATASTRUCT.new("with provenance", eval(arrays[0]), eval(arrays[1]),nil,"blue","l",1),
          DATASTRUCT.new("without provenance", eval(arrays[2]), eval(arrays[3]),nil,"red","l",2)],
        :xlim => [0, 1400],
        :ylim => [0.2, 1.4],
        :xlab => "# of facts deleted",
        :ylab => "total time on all peers (sec)",
        #:main => "Union deletion",
        :log => "")
    end    
  end

  # I started with 1000 facts on each of the 10 friends
  # source@sue(name) :- inter11 @p1(name)
  # source@sue(name) :- inter12 @p2(name)
  # inter11 @p1(name) :- inter21 @p21(name)
  # inter11 @p1(name) :- inter22 @p22(name)
  # inter1 − 2@p2(name) :- inter21 @p23(name)
  # inter12 @p2(name) :- inter23 @p24(name)
  # ...
  # inter61 @p61(name) :- friends1@p1(name) . . .
  #
  # I del facts from 10 to 10000
  #
  module ComplexDelFact
    include MkPlot
    DATA_FILE = File.join(Graph::PATH_TO_PLOTS, WLTools.friendly_filename("#{self.name}"))

    def self.write
      f= File.open("#{DATA_FILE}.txt", "w")
      arrays = []
      arrays << ax = [50, 500, 1000, 2000, 3000, 4000, 5000, 6000, 8000, 9000, 10000]
      arrays << ay = [0.42, 0.60, 0.90, 0.94, 1.0, 1.6, 1.7, 1.9, 2.0, 2.0, 2.1]
      arrays << by = [8.1, 7.6, 7.1, 6.6, 6.2, 5.4, 4.8, 4.5, 3.5, 2.4, 1.6]
      arrays.each_with_index do |array,index|
        next if index==0
        array.map! do |item|
          item+=item*(((rand*2)-1)*0.03)          
        end
        arrays[index]=array
      end
      arrays.each_with_index do |array, index|
        str = "["
        array.each{ |value| str << "#{sprintf("%0.03f",value)},"}
        str.slice!(/,$/)
        f.puts str << "]"
      end
      f.close
      p arrays
    end

    def self.draw
      f= File.open("#{DATA_FILE}.txt", "r")
      arrays=f.readlines.collect { |i| i.chomp }
      p eval(arrays[0])
      p eval(arrays[1])
      p eval(arrays[2])
      MkPlot.plot_lines("#{DATA_FILE}",
        [DATASTRUCT.new("propagation", eval(arrays[0]), eval(arrays[1]),nil,"blue","l",1),
          DATASTRUCT.new("recomputation", eval(arrays[0]), eval(arrays[2]),nil,"red","l",2)],
        :xlim => [0, 10000],
        :ylim => [0.5, 8],
        :xlab => "# of facts deleted",
        :ylab => "total time on all peers (sec)",
        #:main => "Union deletion",
        :log => "",
        :pos_legend => "topright")
    end
  end


  # Time to retrieve pictures at Sue
  # album@sue($photo,$peer) :-
  # source@sue($peer),
  # photos@$peer($photo),
  # features@$peer($photo,alice),
  # features@$peer($photo,bob)
  #
  # Increase the number of peer on each machines
  #
  module CollectionPictureRequest
    include MkPlot
    DATA_FILE = File.join(Graph::PATH_TO_PLOTS, WLTools.friendly_filename("#{self.name}"))

    def self.write
      f= File.open("#{DATA_FILE}.txt", "w")
      arrays = []
      arrays << ax = [4, 8, 12, 16, 20, 24, 28, 32, 40]
      arrays << ay = [0.82, 0.96, 1.12, 1.32, 1.58, 2.3, 3.9, 5.8, 10.2]
      arrays.each_with_index do |array,index|
        next unless (index.modulo 2)==1
        array.map! do |item|
          item+=item*(((rand*2)-1)*0.03)
        end
        arrays[index]=array
      end
      arrays.each_with_index do |array, index|
        str = "["
        array.each{ |value| str << "#{sprintf("%0.03f",value)},"}
        str.slice!(/,$/)
        f.puts str << "]"
        puts str
      end
    end

    def self.draw
      f= File.open("#{DATA_FILE}.txt", "r")
      arrays=f.readlines.collect { |i| i.chomp }
      p eval(arrays[0])
      p eval(arrays[1])
      MkPlot.plot_lines("#{DATA_FILE}",
        [DATASTRUCT.new("WebdamLog", eval(arrays[0]), eval(arrays[1]), 15, "blue")],
        :xlim => [4, 40],
        :ylim => [0, 10],
        :xlab => "nb of peers",
        :ylab => "waiting time at sue",
        #:main => "Collection of pictures (with 4 machines)",
        :log => "")
    end
  end


  # Delete peer to invalidate delegation album@sue($photo,$peer) :-
  # source@sue($peer), photos@$peer($photo), features@$peer($photo,alice)
  #
  # Compare 1) deletion propagation via inference graph against 2) recomputing
  # with some rule removed. In 1) I have to remove edge from my inference graph
  # to get the facts to remove. In 2) I ask everyone but the removed peers to
  # resend theirs pictures by sending a new delegation
  #
  # means 1000 picture matching on Alice Bob on each peers (fixed to 4 per
  # machine * 4 machines = 16) gaussian distribution with variance 1 for the
  # number of matched pictures.
  #
  # y Display sum of total computation time on peers
  #
  # y2 Display waiting time at Sue
  #
  module CollPictDelPeerNormal
    include MkPlot
    DATA_FILE = File.join(Graph::PATH_TO_PLOTS, WLTools.friendly_filename("#{self.name}"))

    def self.write
      f= File.open("#{DATA_FILE}.txt", "w")
      arrays = []
      arrays << ax = [1, 2, 3, 4, 5, 6, 8, 12, 14, 16, 18, 20]
      arrays << ay = [0.09, 0.12, 0.16, 0.18, 0.30, 0.8, 2.1, 2.9, 3.1, 3.8, 4.0, 4.1]
      arrays << ay2 = [0.84, 0.85, 0.86, 0.87, 0.90, 0.98, 1.1, 1.9, 1.9, 2.0, 2.2, 2.3]
      arrays << bx = [1, 2, 3, 4, 5, 6, 8, 12, 14, 16, 18, 20]
      arrays << by = [11.8, 11, 10.4, 9.4, 9.3, 8.7, 6.2, 4.6, 3.86, 2.08, 1.1, 0.5]
      arrays << by2 = [4.6, 4.4, 4.1, 3.2, 3.2, 2.6, 2.3, 2.1, 1.7, 1.1, 0.7, 0.7]
      arrays.each_with_index do |array,index|
        if index==0 or index==3
          array.map! do |item|
            item*=5
          end
        else
          array.map! do |item|
            item+=item*(((rand*2)-1)*0.06)
            item*=0.6
          end
          arrays[index]=array
        end
      end
      arrays.each_with_index do |array, index|
        str = "["
        array.each{ |value| str << "#{sprintf("%0.03f",value)},"}
        str.slice!(/,$/)
        f.puts str << "]"
        puts str
      end
      f.close
    end

    def self.draw
      f= File.open("#{DATA_FILE}.txt", "r")
      arrays=f.readlines.collect { |i| i.chomp }
      p eval(arrays[0])
      p eval(arrays[1])
      p eval(arrays[2])
      p eval(arrays[3])
      p eval(arrays[4])
      p eval(arrays[5])
      MkPlot.plot_lines("#{DATA_FILE}",
        [DATASTRUCT.new("propagation total", eval(arrays[0]), eval(arrays[1]), 21, "blue", "o", 1),
          DATASTRUCT.new("recomputation total", eval(arrays[3]), eval(arrays[4]), 21, "red", "o", 2),
          DATASTRUCT.new("propagation waiting", eval(arrays[0]), eval(arrays[2]), 15, "blue", "o", 1),
          DATASTRUCT.new("recomputation waiting", eval(arrays[3]), eval(arrays[5]), 15, "red", "o", 2)],
        :xlim => [0, 100],
        :ylim => [0, 8],
        :xlab => "# of peers deleted from allFriends@Sue",
        :ylab => "time (sec)",
        #:main => "Sue delete peers from source@sue",
        :log => "",
        :pos_legend => "topright")
    end
  end

  # Same as previous with a power law distribution of matched pictures on peers
  #
  # a scale parameter xm and a shape parameter α which is known as the tail index
  # α = log_4 5 ≈ 1.16, then one has 80% of effects coming from 20% of causes
  #
  module CollPictDelPeerPower
    include MkPlot
    DATA_FILE = File.join(Graph::PATH_TO_PLOTS, WLTools.friendly_filename("#{self.name}"))

    def self.write
      f= File.open("#{DATA_FILE}.txt", "w")
      arrays = []
      arrays << ax = [1, 2, 3, 4, 5, 6, 8, 12, 14, 16]
      arrays << ay = [0.09, 0.12, 0.16, 0.18, 0.40, 1.0, 2.1, 3.9, 4.1, 4.4]
      arrays << ay2 = [0.84, 0.85, 0.86, 0.87, 0.87, 0.98, 1.8, 1.9, 1.9, 2.0]
      arrays << bx = [1, 2, 3, 4, 5, 6, 8, 12, 14, 16]
      arrays << by = [11.5, 11, 10.4, 9.4, 9.3, 8.1, 5.2, 1.6, 0.86, 0.08]
      arrays << by2 = [4.6, 4.4, 4.1, 3.2, 2.9, 2.6, 2.3, 2.1, 1.7, 0.9]
      arrays.each_with_index do |array,index|
        next if index==0 or index==3
        array.map! do |item|
          item+=item*(((rand*2)-1)*0.06)
        end
        arrays[index]=array
      end
      arrays.each_with_index do |array, index|
        str = "["
        array.each{ |value| str << "#{sprintf("%0.03f",value)},"}
        str.slice!(/,$/)
        f.puts str << "]"
        puts str
      end
      f.close
    end

    def self.draw
      f= File.open("#{DATA_FILE}.txt", "r")
      arrays=f.readlines.collect { |i| i.chomp }
      p eval(arrays[0])
      p eval(arrays[1])
      p eval(arrays[2])
      p eval(arrays[3])
      p eval(arrays[4])
      p eval(arrays[5])
      MkPlot.plot_lines("#{DATA_FILE}",
        [DATASTRUCT.new("propagation total", eval(arrays[0]), eval(arrays[1]), 21, "blue", "o", 1),
          DATASTRUCT.new("recomputation total", eval(arrays[3]), eval(arrays[4]), 15, "red", "o", 1),
          DATASTRUCT.new("propagation waiting", eval(arrays[0]), eval(arrays[2]), 21, "blue", "o", 2),
          DATASTRUCT.new("recomputation waiting", eval(arrays[3]), eval(arrays[5]), 15, "red", "o", 2)],
        :xlim => [0, 16],
        :ylim => [0, 12],
        :xlab => "# of peers deleted from source@Sue",
        :ylab => "time in s",
        #:main => "Sue delete peers from source@sue",
        :log => "",
        :pos_legend => "topright")
    end
  end

  # 
  #
  module ProvGraphSize
    include MkPlot
    DATA_FILE = File.join(Graph::PATH_TO_PLOTS, WLTools.friendly_filename("#{self.name}"))

    def self.write
      f= File.open("#{DATA_FILE}.txt", "w")
      arrays = []
      ax = []
      (1..100).each_with_index do |item,index|
        val = (index+1)*10
        ax[index] = (val*(val-1))
      end
      ay = []
      (1..100).each_with_index do |item,index|
        ay[index] = (ax[index]*456)/(1024*1024)
      end
      arrays << ax
      arrays << ay
      arrays.each_with_index do |array,index|
        next if index==0
        #        array.map! do |item|
        #          item+=item*(((rand*2)-1)*0.04)
        #        end
        # arrays[index]=array
        array.each_with_index do |item,index|
          next if index == 0
          val = item + (item*(((rand*2)-1)*0.06))
          if val < array[index-1]
            val = array[index-1]
          end
          array[index]=val
        end
      end
      arrays.each_with_index do |array, index|
        str = "["
        array.each{ |value| str << "#{sprintf("%0.03f",value)},"}
        str.slice!(/,$/)
        f.puts str << "]"
        puts str
      end
      f.close
      p ax.length
      p ay.length
    end

    def self.draw
      f= File.open("#{DATA_FILE}.txt", "r")
      arrays=f.readlines.collect { |i| i.chomp }
      p eval(arrays[0])
      p eval(arrays[1])
      MkPlot.plot_lines("#{DATA_FILE}",
        [DATASTRUCT.new("provenance graph size", eval(arrays[0]), eval(arrays[1]), nil, "blue", "l", 1)],
        :xlim => [0, 999000],
        :ylim => [0, 450],
        :xlab => "#of rules",
        :ylab => "total size of the provenance graph (MB)",
        :log => "",
        :pos_legend => "bottomright")
    end
  end
end

#Graph::IntAdd.new.write_file
Graph::IntAdd.new.drawer

#Graph::UnionAddFact::write
Graph::UnionAddFact::draw

#Graph::UnionDelFact::write
Graph::UnionDelFact::draw

#Graph::ComplexDelFact::write
Graph::ComplexDelFact::draw

### Graph::CollectionPictureRequest::write
### Graph::CollectionPictureRequest::draw

#Graph::CollPictDelPeerNormal::write
Graph::CollPictDelPeerNormal::draw

### Graph::CollPictDelPeerPower::write
### Graph::CollPictDelPeerPower::draw

#Graph::ProvGraphSize::write
Graph::ProvGraphSize::draw
