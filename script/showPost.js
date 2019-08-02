function showPost(id) {
  let post = document.getElementById(id);
  if (post.style.display == "none") {
    post.style.display = "block";
  } else {
    post.style.display = "none";
  }
}
