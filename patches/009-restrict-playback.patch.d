From 91908d4b3ff25cca88d56f21f6e5efdd3d83282e Mon Sep 17 00:00:00 2001
From: Emilien Devos <contact@emiliendevos.be>
Date: Sat, 8 Oct 2022 13:34:52 +0200
Subject: [PATCH 1/1] enforce playback from main website

---
 assets/js/comments.js                     |  2 ++
 assets/js/player.js                       |  4 ++--
 assets/js/watch.js                        |  1 +
 src/invidious/routes/api/v1/videos.cr     | 16 ++++++++++++++++
 src/invidious/views/components/player.ecr | 11 +++++++----
 src/invidious/views/watch.ecr             |  1 +
 6 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/assets/js/comments.js b/assets/js/comments.js
index 35ffa96e..412a9f7b 100644
--- a/assets/js/comments.js
+++ b/assets/js/comments.js
@@ -62,6 +62,7 @@ function get_youtube_comments() {
     var url = baseUrl +
         '?format=html' +
         '&hl=' + video_data.preferences.locale +
+        '&hmac_key=' + video_data.hmac_key +
         '&thin_mode=' + video_data.preferences.thin_mode;
 
     if (video_data.ucid) {
@@ -129,6 +130,7 @@ function get_youtube_replies(target, load_more, load_replies) {
     var url = baseUrl +
         '?format=html' +
         '&hl=' + video_data.preferences.locale +
+        '&hmac_key=' + video_data.hmac_key +
         '&thin_mode=' + video_data.preferences.thin_mode +
         '&continuation=' + continuation;
 
diff --git a/assets/js/player.js b/assets/js/player.js
index bb53ac24..43bd902f 100644
--- a/assets/js/player.js
+++ b/assets/js/player.js
@@ -372,7 +372,7 @@ if (!video_data.params.listen && video_data.params.quality === 'dash') {
 }
 
 player.vttThumbnails({
-    src: '/api/v1/storyboards/' + video_data.id + '?height=90',
+    src: '/api/v1/storyboards/' + video_data.id + '?height=90&hmac_key=' + video_data.hmac_key,
     showTimestamp: true
 });
 
@@ -398,7 +398,7 @@ if (!video_data.params.listen && video_data.params.annotations) {
             }
         });
 
-        helpers.xhr('GET', '/api/v1/annotations/' + video_data.id, {
+        helpers.xhr('GET', '/api/v1/annotations/' + video_data.id + "?hmac_key=" + video_data.hmac_key, {
             responseType: 'text',
             timeout: 60000
         }, {
diff --git a/assets/js/watch.js b/assets/js/watch.js
index 26ad138f..0242f31b 100644
--- a/assets/js/watch.js
+++ b/assets/js/watch.js
@@ -115,6 +115,7 @@ function get_reddit_comments() {
 
     var url = '/api/v1/comments/' + video_data.id +
         '?source=reddit&format=html' +
+        '&hmac_key=' + video_data.hmac_key +
         '&hl=' + video_data.preferences.locale;
 
     var onNon200 = function (xhr) { comments.innerHTML = fallback; };
diff --git a/src/invidious/routes/api/v1/videos.cr b/src/invidious/routes/api/v1/videos.cr
index 449c9f9b..82fc9b0f 100644
--- a/src/invidious/routes/api/v1/videos.cr
+++ b/src/invidious/routes/api/v1/videos.cr
@@ -27,6 +27,10 @@ module Invidious::Routes::API::V1::Videos
     id = env.params.url["id"]
     region = env.params.query["region"]? || env.params.body["region"]?
 
+    if OpenSSL::HMAC.hexdigest(:sha1, HMAC_KEY, id) != env.params.query["hmac_key"]?
+      return error_json(403, "Incorrect key")
+    end
+
     if id.nil? || id.size != 11 || !id.matches?(/^[\w-]+$/)
       return error_json(400, "Invalid video ID")
     end
@@ -170,6 +174,10 @@ module Invidious::Routes::API::V1::Videos
     id = env.params.url["id"]
     region = env.params.query["region"]?
 
+    if OpenSSL::HMAC.hexdigest(:sha1, HMAC_KEY, id) != env.params.query["hmac_key"]?
+      return error_json(403, "Incorrect key")
+    end
+
     begin
       video = get_video(id, region: region)
     rescue ex : NotFoundException
@@ -234,6 +242,10 @@ module Invidious::Routes::API::V1::Videos
     source = env.params.query["source"]?
     source ||= "archive"
 
+    if OpenSSL::HMAC.hexdigest(:sha1, HMAC_KEY, id) != env.params.query["hmac_key"]?
+      return error_json(403, "Incorrect key")
+    end
+
     if !id.match(/[a-zA-Z0-9_-]{11}/)
       haltf env, 400
     end
@@ -303,6 +315,10 @@ module Invidious::Routes::API::V1::Videos
 
     id = env.params.url["id"]
 
+    if OpenSSL::HMAC.hexdigest(:sha1, HMAC_KEY, id) != env.params.query["hmac_key"]?
+      return error_json(403, "Incorrect key")
+    end
+
     source = env.params.query["source"]?
     source ||= "youtube"
 
diff --git a/src/invidious/views/components/player.ecr b/src/invidious/views/components/player.ecr
index c3c02df0..d046c791 100644
--- a/src/invidious/views/components/player.ecr
+++ b/src/invidious/views/components/player.ecr
@@ -1,10 +1,11 @@
 <video style="outline:none;width:100%;background-color:#000" playsinline poster="<%= thumbnail %>"
     id="player" class="on-video_player video-js player-style-<%= params.player_style %>"
+    <% hmac_key = OpenSSL::HMAC.hexdigest(:sha1, HMAC_KEY, video.id) %>
     <% if params.autoplay %>autoplay<% end %>
     <% if params.video_loop %>loop<% end %>
     <% if params.controls %>controls<% end %>>
     <% if (hlsvp = video.hls_manifest_url) && !CONFIG.disabled?("livestreams") %>
-        <source src="<%= URI.parse(hlsvp).request_target %><% if params.local %>?local=true<% end %>" type="application/x-mpegURL" label="livestream">
+        <source src="<%= URI.parse(hlsvp).request_target %><% if params.local %>?local=true&hmac_key=<%= hmac_key %><% end %>" type="application/x-mpegURL" label="livestream">
     <% else %>
         <% if params.listen %>
             <% # default to 128k m4a stream
@@ -20,6 +21,7 @@
 
                audio_streams.each_with_index do |fmt, i|
                 src_url  = "/latest_version?id=#{video.id}&itag=#{fmt["itag"]}"
+                src_url += "&hmac_key=#{hmac_key}"
                 src_url += "&local=true" if params.local
 
                 bitrate = fmt["bitrate"]
@@ -34,7 +36,7 @@
             <% end %>
         <% else %>
             <% if params.quality == "dash" %>
-                <source src="/api/manifest/dash/id/<%= video.id %>?local=true&unique_res=1" type='application/dash+xml' label="dash">
+                <source src="/api/manifest/dash/id/<%= video.id %>?local=true&unique_res=1&hmac_key=<%= hmac_key %>" type='application/dash+xml' label="dash">
             <% end %>
 
             <%
@@ -42,6 +44,7 @@
             fmt_stream.sort_by! {|f| params.quality == f["quality"] ? 0 : 1 }
             fmt_stream.each_with_index do |fmt, i|
                 src_url  = "/latest_version?id=#{video.id}&itag=#{fmt["itag"]}"
+                src_url += "&hmac_key=#{hmac_key}"
                 src_url += "&local=true" if params.local
 
                 quality = fmt["quality"]
@@ -57,11 +60,11 @@
         <% end %>
 
         <% preferred_captions.each do |caption| %>
-            <track kind="captions" src="/api/v1/captions/<%= video.id %>?label=<%= caption.name %>" label="<%= caption.name %>">
+            <track kind="captions" src="/api/v1/captions/<%= video.id %>?label=<%= caption.name %>&hmac_key=<%= hmac_key %>" label="<%= caption.name %>">
         <% end %>
 
         <% captions.each do |caption| %>
-            <track kind="captions" src="/api/v1/captions/<%= video.id %>?label=<%= caption.name %>" label="<%= caption.name %>">
+            <track kind="captions" src="/api/v1/captions/<%= video.id %>?label=<%= caption.name %>&hmac_key=<%= hmac_key %>" label="<%= caption.name %>">
         <% end %>
     <% end %>
 </video>
diff --git a/src/invidious/views/watch.ecr b/src/invidious/views/watch.ecr
index 62a154a4..cf6d8981 100644
--- a/src/invidious/views/watch.ecr
+++ b/src/invidious/views/watch.ecr
@@ -64,6 +64,7 @@ we're going to need to do it here in order to allow for translations.
     "premiere_timestamp" => video.premiere_timestamp.try &.to_unix,
     "vr" => video.is_vr,
     "projection_type" => video.projection_type,
+    "hmac_key" => OpenSSL::HMAC.hexdigest(:sha1, HMAC_KEY, video.id),
     "local_disabled" => CONFIG.disabled?("local"),
     "support_reddit" => true
 }.to_pretty_json
-- 
2.42.0

