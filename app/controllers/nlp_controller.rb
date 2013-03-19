class NlpController < ApplicationController
  #require 'treat'
  
  def post
    @text = params[:query]
    db_blob = JSON.parse(params[:db_json])

    @results = []

    @segments = []

    pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
    processed = StanfordCoreNLP::Annotation.new(@text)
    pipeline.annotate(processed)
    
    processed.get(:sentences).each do |sentence|
      # Syntatical dependencies
      @results << sentence.get(:tree).to_s
      intermediate = ''
      sentence.get(:tokens).each do |token|
        # Default annotations for all tokens
        @results << '1: ' + token.get(:value).to_s
        @results << '2: ' + token.get(:original_text).to_s
        @results << '3: ' + token.get(:character_offset_begin).to_s
        @results << '4: ' + token.get(:character_offset_end).to_s
        # POS returned by the tagger
        @results << '5: ' + token.get(:part_of_speech).to_s
        if (token.get(:part_of_speech).to_s == "IN" || token.get(:part_of_speech).to_s.start_with?('JJ'))
          intermediate << ">"
        end
        intermediate += token.get(:value).to_s + ' '
        if token.get(:named_entity_tag).to_s == 'O' && (token.get(:part_of_speech).to_s == "CC" || token.get(:part_of_speech).to_s.start_with?('NN'))
          @segments << intermediate
          intermediate = ''
        end
        # Lemma (base form of the token)
        @results << '6: ' + token.get(:lemma).to_s
        # Named entity tag
        @results << '7: ' + token.get(:named_entity_tag).to_s
        # Coreference
        @results << '8: ' + token.get(:coref_cluster_id).to_s
        @results << '9: ' + token.get(:coref_graph).to_s
        # Also of interest: coref, coref_chain, 
        # coref_cluster, coref_dest, coref_graph.
      end
      @segments << intermediate
      @results << ''
      @results << ''
    end
    
    @query = @text.split(" ")
    
    #@sqlQuery = Nlp::SqlQuery.new(query)
    #@sqlQuery.addTable("employees", 0)
    #@sqlQuery.addField("employees", "*", 0)
    #@sqlQuery.addCondition("employees", "hire_date", "<", "August 2011")
    #@sqlQuery.addCondition("employees", "amount", ">", "1000")
    
=begin

    ## TREAT isn't working right now
    # @section = Paragraph 'Get all employees who were hired before August 2011 and have been paid more than $1,000 since September 2012'

    # Chunk: split the titles and paragraphs.
    # Segment: perform sentence segmentation.
    # Parse: parse the syntax of each sentence.
    # @section.do :segment, :parse




    tgr = EngTagger.new
    @results = []

    @results << "EngTagger"

    tagged = tgr.get_readable(query).split
    @results << tagged
    @results << query

#    @results << 'employees'.stem
#    @results << 'employee'.stem
#    @results << 'hire_date'.stem
#    @results << 'hired'.stem

    words = tagged.inject([]){|l,x| l + [/(.*)\/[A-Z]+$/.match(x)[1]]}
    @results << "words: " + words.inspect
#    @results << "json parse test: " + JSON.parse("{\"tables\":[{\"name\":\"employees\",\"fields\":[{\"name\":\"first_name\",\"type\":\"string\"},{\"name\":\"id\",\"type\":\"int\"}]}]}").inspect
    @results << "blob" + db_blob.inspect
    
    #####
    #
    # Find Table
    #
    #####
    @results << "Table names:"
    table_names = []
    for i in 0 ... words.size
      db_blob["tables"].each do |table|
        if table["name"].stem == words[i].stem
          @results << "Table name: " + table["name"].stem + " at index " + i.to_s + " word stem: " + words[i].stem
          @sqlQuery.addTable(table["name"], i)
        end
      end
    end



    #####
    #
    # Find Dates
    #
    #####
    dates = []
    for i in 0 ... words.size
      for j in i ... words.size
        #@results << ">>>> " + words[i,j-i+1].join(' ')
        #@results << "i: " + i.to_s + " , j: " + j.to_s + ", range for all?: " + (i..j).inspect
        # TODO: move the date pos check to a separate method
        if (i..j).all?{|x| pos = /[A-Z]+$/.match(tagged[x])[0]
                             pos == "NNP" ||
                             pos == "NN" ||
                             pos == "CD" ||
                             pos == "JJ" ||
                             (x != i && x != j && pos == "PPC") ||
                             (x != i && x != j && pos == "IN")}
          parsed = Chronic.parse(words[i,j-i+1].join(' '))
          if parsed != nil
            dates << [i,j]
          end
        end
      end
    end

    half_reduced_dates = Hash.new(words.length)
    dates.each do |range|
      half_reduced_dates[range[1]] = [half_reduced_dates[range[1]],range[0]].min
    end
    reduced_dates = Hash.new(0)
    half_reduced_dates.each do |range|
      reduced_dates[range[1]] = [reduced_dates[range[1]],range[0]].max
    end
    dates = []
    reduced_dates.each do |range|
      dates << [range[0],range[1]]
    end

    dates.each do |range|
      i = range[0]
      j = range[1]
      @results << words[i,j-i+1].join(' ')
      @results << Chronic.parse(words[i,j-i+1].join(' '))
    end
=end
  end
end
