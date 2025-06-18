// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

import SearchController from "controllers/search_controller"
import ProfileController from "controllers/profile_controller";
import ProfileEditController from "controllers/profile_edit_controller";

application.register("search", SearchController)
application.register("profile", ProfileController);
application.register("profile-edit", ProfileEditController);

eagerLoadControllersFrom("controllers", application)
