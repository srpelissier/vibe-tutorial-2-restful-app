module service;

import std.conv;
import vibe.d;

class MongoService
{
  private MongoCollection collection;
  const string title;

  this(MongoCollection collection, string title = "")
  {
    this.collection = collection;
    this.title = title;
  }

  void test(HTTPServerRequest req, HTTPServerResponse res)
  {
    logInfo("MongoService: TEST");
    //res.writeBody("TEST");
    res.writeJsonBody(collection.find!Json.array);
  }


  void index()
  {
    logInfo("MongoService: GET /");
    render!("index.dt", title);
  }

  void postAdduser(string username, string email, string fullname, uint age, string location, string gender, HTTPServerResponse res)
  {
    import vibe.utils.validation;

    logInfo("MongoService: POST /adduser : ", username);
    enforce(age < 200, "wrong age");

    auto bson = Bson.emptyObject;
    bson.username = validateUserName(username);
    bson.email = validateEmail(email);
    bson.fullname = fullname;
    bson.age = age;
    bson.location = location;
    bson.gender = gender.toLower;

    collection.insert(bson);
    res.writeBody("");
  }

  void getUserList(HTTPServerRequest req, HTTPServerResponse res)
  {
    logInfo("MongoService : GET /users/userlist");
    res.writeJsonBody(collection.find!Json.array);
    //return Json(collection.find!Json.array);
  }

  @path("deleteuser/:id")
  @method(HTTPMethod.DELETE)
  void pullOutUser(BsonObjectID _id, HTTPServerResponse res)
  {
    logInfo(text("MongoService: GET /deleteuser/", _id));
    collection.remove(["_id": _id]);
    res.writeBody("");
  }
}
