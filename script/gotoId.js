function gotoId() {
  if ( window.location.hash ) {
    let hash = window.location.hash.substring(1);
    showPost(hash);
  }
}
