import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";

actor {
    public type Message = Text;

    public type Microblog = actor {
        follow: shared (Principal) -> async ();
        follows: shared query () -> async [Principal];
        post: shared (Text) -> async ();
        posts: shared query () -> async [Message];
        timeline: shared () -> async [Message];
    };

    var followed : List.List<Principal> = List.nil();
    public shared func follow(id: Principal) :async () {
        followed := List.push(id, followed);
    };
    public shared query func follows() :async [Principal]{
        List.toArray(followed);
    };

    var messages : List.List<Message> = List.nil();
    public shared func post(msg: Message) :async () {
        messages := List.push(msg, messages);
    };
    public shared query func posts() :async [Message]{
        List.toArray(messages);
    };

    public shared func timeline() :async [Message]{
        var feeds : List.List<Message> = List.nil();

        for (canisterId in Iter.fromList(followed)) {
            let canister : Microblog = actor(Principal.toText(canisterId));
            let msgs = await canister.posts();
            for(msg in Iter.fromArray(msgs)) {
                feeds := List.push(msg, feeds);
            }
        };
        List.toArray(feeds);
    };
};