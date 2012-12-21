class NlpController < ApplicationController
  def post
    text = params[:query]
    tgr = EngTagger.new
    tagged = tgr.add_tags(text)
    @result = tgr.get_readable(text)
  end
end
