xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{@user.name} <#{@user.username}>"
    xml.description "Latest 10 microposts"
    xml.link feed_user_url(@user, :format => :rss)

    @microposts.each do |micropost|
      xml.item do
        xml.title micropost.content
        xml.pubDate micropost.created_at.to_s(:rfc822)
      end
    end
  end
end