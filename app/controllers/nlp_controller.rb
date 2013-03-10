class NlpController < ApplicationController
  def post
    @sqlQuery = Nlp::SqlQuery.new
    @sqlQuery.addTable("employees")
    @sqlQuery.addField("employees", "*")
    @sqlQuery.addCondition("employees", "hire_date", "<", "August 2011")
    @sqlQuery.addCondition("employees", "amount", ">", "1000")
    
    query = params[:query]
    db_blob = JSON.parse(params[:db_json])

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
  end
end
