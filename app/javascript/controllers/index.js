// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

import SearchController from "controllers/search_controller"
import ProfilePictureController from "controllers/profile_picture_controller"
import ProfileEditController from "controllers/profile_edit_controller"
import CoverArtController from "controllers/cover_art_controller"

application.register("search", SearchController)
application.register("profile-picture", ProfilePictureController)
application.register("profile-edit", ProfileEditController)
application.register("cover-art", CoverArtController)

eagerLoadControllersFrom("controllers", application)
