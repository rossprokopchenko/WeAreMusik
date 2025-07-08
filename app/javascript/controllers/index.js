// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

import SearchController from "controllers/search_controller"
import ProfilePictureController from "controllers/profile_picture_controller"
import ProfileEditController from "controllers/profile_edit_controller"
import ImageLoaderController from "controllers/image_loader_controller"
import ClickRowController from "controllers/click_row_controller"
import DropdownController from "controllers/dropdown_controller"
import ShowAlbumController from "controllers/show_album_controller"
import ShowTrackController from "controllers/show_track_controller"
import FavoriteReleasesController from "controllers/favorite_releases_controller"
import FavoriteArtistsController from "controllers/favorite_artists_controller"

application.register("search", SearchController)
application.register("profile-picture", ProfilePictureController)
application.register("profile-edit", ProfileEditController)
application.register("image-loader-controller", ImageLoaderController)
application.register("click-row-controller", ClickRowController)
application.register("dropdown-controller", DropdownController)
application.register("show-album-controller", ShowAlbumController)
application.register("show-track-controller", ShowTrackController)
application.register("favorite-releases-controller", FavoriteReleasesController)
application.register("favorite-artists-controller", FavoriteArtistsController)

eagerLoadControllersFrom("controllers", application)
