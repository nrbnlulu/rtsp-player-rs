use std::collections::HashMap;

use tokio::sync::RwLock;


struct FlutterGsSession {
    
}


lazy_static::lazy_static! {
    // peer -> peer session, peer session -> ui sessions
    static ref SESSIONS: RwLock<HashMap<String, FlutterGsSession>> = Default::default();
}


