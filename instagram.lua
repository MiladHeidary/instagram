-- luarocks install busted
-- luarocks install lua-requests

local requests = require 'requests'
local json = require 'cjson'
local function getUser(username)
  local output = {
    post = {}
  }
  local html = requests.get{'https://www.instagram.com/'..username..'/'}
  local json_data = html.text:match("<script type=\"text/javascript\">window._sharedData = (.-);</script>")
  if json_data then
    local table_data = json.decode(json_data)
    local data = table_data.entry_data.ProfilePage[1].graphql.user
    output.result = true
    output.following = data.edge_follow.count
    output.followers = data.edge_followed_by.count
    output.post_count = data.edge_owner_to_timeline_media.count
    output.full_name = data.full_name
    output.profile_pic_url_hd = data.profile_pic_url_hd
    output.profile_pic_url = data.profile_pic_url_hd
    output.username = data.username
    output.biography = data.biography
    for k,v in pairs(data.edge_owner_to_timeline_media.edges) do
        caption = #v.node.edge_media_to_caption.edges > 0 and v.node.edge_media_to_caption.edges[1].node.text or ''
        output.post[#output.post+1] = {
        post_type = v.node.__typename,
        comments_disabled = v.node.comments_disabled,
        display_url = v.node.display_url,
        like = v.node.edge_liked_by.count,
        like = v.node.edge_liked_by.count,
        caption = caption,
        post_link = 'https://www.instagram.com/p/'..v.node.shortcode
      }
    end
  else
    output.result = false
  end
  return output
end
