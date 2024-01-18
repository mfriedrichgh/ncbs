use axum::{extract::Path, http::StatusCode, routing::{get, post}, Router};
use chrono::NaiveDateTime;
use sqlx::{postgres::PgPoolOptions, prelude::FromRow};
use std::{path::PathBuf, process::Command};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let app = Router::new()
        .route("/", get(root))
        .route("/clone/:id", post(clone))
        .route("/build/:id", get(build))
        .route("/status/:id", get(status))
        .route("/download/:id", get(download))
        ;

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await?;
    axum::serve(listener, app).await?;
    Ok(())
}

async fn root() -> &'static str {
    "Your princess is in another castle!"
}

async fn build(Path(id): Path<i64>) -> StatusCode {
    println!("Building {}", id);
    let build_path = PathBuf::from("build").join(id.to_string());
    let toml_path = PathBuf::from("repos").join(id.to_string()).join("Cargo.toml");
    // Build the project.
    let cargo_args = [
        "+nightly",
        "-Z",
        "unstable-options",
        "build",
        "-r",
        "--manifest-path",
        &toml_path.to_string_lossy(),
        "--out-dir",
        &build_path.to_string_lossy(),
    ];
    _ = Command::new("cargo").args(&cargo_args).status().unwrap();
    StatusCode::OK
}

async fn status(Path(id): Path<i64>) -> String {
    "done".to_owned()
}

async fn download(Path(id): Path<i64>) -> Vec<u8> {
    println!("Downloading {}", id);
    let build_path = PathBuf::from("build").join(id.to_string());
    let output_path = build_path.join("output.tar.gz");
    // Build the project.
    let tar_args = [
        "-czvf",
        &output_path.to_string_lossy(),
        &build_path.to_string_lossy(),
    ];
    _ = Command::new("tar").args(&tar_args).status().unwrap();
    std::fs::read(&output_path).unwrap()
}

/// Clones a Git project to the local space.
async fn clone(Path(id): Path<i64>) -> StatusCode {
    println!("Cloning {}", id);
    // Make sure the folder for the project is clean (Can fail if didn't exist already so ignore Result).
    let p = PathBuf::from("repos").join(id.to_string());
    _ = std::fs::remove_dir_all(&p);
    // Create a folder for the project.
    std::fs::create_dir_all(&p).unwrap();

    // Retrieve the repository URL from the database.
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect("postgres://postgres:password@db:5432/ncbs_development")
        .await
        .unwrap();
    // Make a simple query to return the given parameter (use a question mark `?` instead of `$1` for MySQL)
    let row: Project =
        sqlx::query_as("SELECT projects.* FROM projects WHERE projects.id = $1 LIMIT 1;")
            .bind(id)
            .fetch_one(&pool)
            .await
            .unwrap();
    // Clone using git.
    let git_args = [
        "clone",
        &row.repo.unwrap(),
        &p.to_string_lossy(),
        "--recurse-submodules",
    ];
    _ = Command::new("git").args(&git_args).status().unwrap();
    return StatusCode::OK;
}

#[derive(Debug, FromRow)]
struct Project {
    id: i64,
    name: Option<String>,
    creator: Option<String>,
    public: Option<bool>,
    repo: Option<String>,
    created: Option<NaiveDateTime>,
    created_at: NaiveDateTime,
    updated_at: NaiveDateTime,
}

