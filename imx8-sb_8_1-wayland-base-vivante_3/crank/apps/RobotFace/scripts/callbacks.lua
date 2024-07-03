local face_files = {
  "images/face_happy.mpeg",
  "images/face_love.mpeg",
  "images/face_mad.mpeg",
  "images/face_stars.mpeg",
  "images/face_HAL.mpeg",
  "images/face_defunct.mpeg",
}

--- Reacts to "chnage_face" event coming from backend
--- @param face - string containing new face state, either happy, love, mad, star, hal and defunct
function cb_incoming_face_change(mapargs)
  local new_face = mapargs.context_event_data.value
  gre.set_value("video_layer.video.image",face_files[new_face])
end
