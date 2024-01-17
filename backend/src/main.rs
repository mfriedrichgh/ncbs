use axum::{
    routing::get, Router, http::StatusCode, extract::Path,
};
use std::process::Command;

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(root))
        .route("/clone/:id", get(clone));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn root() -> &'static str {
    "Your princess is in another castle!"
}

/// Clones a Git project to the local space.
async fn clone(Path(id): Path<usize>) -> StatusCode {
    println!("Got \"{id}\"");
    // Make sure the folder for the project is clean (Can fail if didn't exist already so ignore Result).
    _ = std::fs::remove_dir(id.to_string());
    // Create a folder for the project.
    std::fs::create_dir(id.to_string()).unwrap();
    // Move into the folder.
    std::env::set_current_dir(id.to_string()).unwrap();
    // Retrieve the repository URL from the database.
    // Clone using git.
    let git = Command::new("sh").arg("-c").arg(format!("git clone https://github.com/marv7000/IceBloc . --recurse-submodules")).output().unwrap();
    dbg!(&git);
    return StatusCode::OK;
}