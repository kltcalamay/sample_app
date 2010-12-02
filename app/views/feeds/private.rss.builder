xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{@user.name}'s Status Feed"
    xml.description "@#{@user.username}'s and friends' latest 10 microposts"

    for micropost in @microposts
      xml.item do
        xml.title micropost.content
        xml.description "From: #{micropost.user.name} a.k.a #{micropost.user.username}"
        xml.pubDate micropost.created_at.to_s(:rfc822)
      end
    end
  end
end