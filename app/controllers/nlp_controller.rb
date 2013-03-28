class NlpController < ApplicationController
  #require 'treat'
  
  def post
    @text = params[:query]
    @query = @text.split(" ")
    db_json = JSON.parse(params[:db_json])
    
   
    @sqlQuery = Nlp::SqlQuery.new(@query)
    
    @results = []
    
    @results << db_json
    
    @sqlQuery.addTable('employees', 0)
    @sqlQuery.addField("employees", "*", 0)
    # TODO: parse db_json
    parsePhrase(@sqlQuery, @text, '', 'employees', lemmatizeList(%w{name height hired hours}))
    
    # Types: numeric, string, date
    # CD : cardinal number
    # NP == Date
    # else = ignore column & JJ/IN => string
    pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
    processed = StanfordCoreNLP::Annotation.new(@text)
    pipeline.annotate(processed)
    
    
    #asking for processed.get(:tree) will return nothing. We can only make trees from individual sentances
    processed.get(:sentences).each do |sentence|
      # Syntatical dependencies
      @results << sentence.get(:tree).to_s
      #if we want to traverse this tree we can use rubies each method to call the java iterator for the treenode class.
      #this will traverse the tree in a depth first search fashion
      sentence.get(:tree).each do |treeNode|
        #These methods come standard with every ruby object, they will allow us to have access in other ways than the .each iterator method
        puts treeNode.to_a
        puts treeNode.to_s
        
        #return the score of the node(not sure wtf this actually means, I imagine it has to do with probable correctness)
        puts treeNode.score
        
        #To access the other interesting methods(non_symbol methods indicate that they are part of the library), we can run
        #treeNode.methods.select{|e| e != e.to_sym}
        #["score", "children", "label", "treeFactory", "nodeString", "setChildren", "setLabel", "setScore", "equals", "toString", "labelFactory", "prune", "isUnaryRewrite", "firstChild", "taggedYield", "pennPrint", "indentedListPrint", "deepCopy", "indexLeaves", "mapDependencies", "taggedLabeledYield", "getLeaves", "isLeaf", "labels", "setValue", "getSpan", "removeChild", "getChild", "iterator", "size", "yield", "depth", "value", "pennString", "headTerminal", "headPreTerminal", "percolateHeads", "yieldWords", "yieldHasWord", "labeledYield", "preTerminalYield", "setLabels", "flatten", "subTrees", "treeSkeletonCopy", "spliceOut", "skipRoot", "ancestor", "postOrderNodeList", "preOrderNodeList", "addChild", "setChild", "dominates", "dominationPath", "pathNodeToNode", "joinNode", "cCommands", "siblings", "insertDtr", "leftCharEdge", "rightCharEdge", "nodeNumber", "getNodeNumber", "percolateHeadIndices", "indexSpans", "isPrePreTerminal", "objectIndexOf", "getChildrenAsList", "lastChild", "upperMostUnary", "setSpans", "constituents", "localTrees", "toStructureDebugString", "toStringBuilder", "printLocalTree", "indentedXMLPrint", "numChildren", "localTree", "isPreTerminal", "isPhrasal", "subTreeList", "hashCode", "setFromString", "dependencies", "parent", "transform", "toArray", "retainAll", "addAll", "isEmpty", "clear", "contains", "remove", "add", "containsAll", "removeAll", "wait", "notify", "notifyAll", "getClass"]
      end
      
      
      
      sentence.get(:tokens).each do |token|
        # Default annotations for all tokens
        @results << '1: ' + token.get(:value).to_s
        @results << '2: ' + token.get(:original_text).to_s
        @results << '3: ' + token.get(:character_offset_begin).to_s
        @results << '4: ' + token.get(:character_offset_end).to_s
        # POS returned by the tagger
        @results << '5: ' + token.get(:part_of_speech).to_s
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
      @results << ''
      @results << ''
    end
    
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
    @results << "blob" + db_json.inspect
    
    #####
    #
    # Find Table
    #
    #####
    @results << "Table names:"
    table_names = []
    for i in 0 ... words.size
      db_json["tables"].each do |table|
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
  def parsePhrase(sqlQueryObj, phrase, sugg_column, sugg_table, lemmatized_db)
    pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
    processed = StanfordCoreNLP::Annotation.new(phrase)
    pipeline.annotate(processed)
    
    table = sugg_table
    column = sugg_column
    value = []
    operator = []
    processed.get(:sentences).each do |sentence|
      # Syntatical dependencies
      sentence.get(:tokens).each do |token|
        val = token.get(:original_text).to_s
        pos = token.get(:part_of_speech).to_s
        lemma = token.get(:lemma).to_s
        named_entity = token.get(:named_entity_tag).to_s
        # Check for column name
        if pos.start_with? 'NN' or pos.start_with? 'VB'
          lemmatized_db.get(:tokens).each do |db_col|
            if lemma == db_col.get(:lemma).to_s
              column = db_col.get(:original_text).to_s
            end
          end
        # Check for operator
        elsif pos.start_with? 'JJ' or pos.start_with? 'IN'
          # if no column yet, check this for column
          operator << val 
        # Else is value
        else
          value << val
        end
      end
    end
    
    sqlQueryObj.addCondition(table, column, operator.join(' '), value.join(' '))
    
  end
  def lemmatizeList(list)
    pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma)
    processed = StanfordCoreNLP::Annotation.new(list.join(' '))
    pipeline.annotate(processed)
    processed.get(:sentences).each do |sentence|
      return sentence
    end
  end
end
