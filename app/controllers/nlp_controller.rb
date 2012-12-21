class NlpController < ApplicationController
  def post
    text = params[:query]
    tgr = EngTagger.new
    tagged = tgr.add_tags(text)
    @results = []
    @results << tgr.get_readable(text)
    @results << tgr.get_nouns(tagged)
  end
end
