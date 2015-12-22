module app;

import vibe.d;
import service;
import std.stdio;

shared static this()
{
  immutable string title = "vibe.d";
  
  logInfo("Connecting to DB...");
  auto db = connectMongoDB("localhost").getDatabase("vibed");
  auto collection = db["userlist"];

  logInfo("Creating service...");
  auto mongoService = new MongoService(collection, title);
  auto mongoServiceSettings = new WebInterfaceSettings;
  mongoServiceSettings.urlPrefix = "/users";
  logInfo("Setup router...");
  auto router = new URLRouter;
  router.registerWebInterface(mongoService, mongoServiceSettings);
  router
    .get("/", (req, res)
        { res.redirect("/users"); })
    .get("/users/userlist", &mongoService.getUserList)
    .get("*", serveStaticFiles("public/"));
  
    logInfo("Setup HTTP server...");
    auto settings = new HTTPServerSettings;
    with(settings)
    {
      bindAddresses = ["127.0.0.1"];
      port = 8080;
      errorPageHandler =
        (req, res, error)
        {
          with(error) res.writeBody(
              format("Code: %s\n Message: %s\n Exception: %s", code, message, exception ? exception.msg : ""));};
    }

    // Listening http://127.0.0.1:8080
    listenHTTP(settings, router);
}
