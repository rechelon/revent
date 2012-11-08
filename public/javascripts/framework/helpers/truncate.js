function truncate(text, length){
  if ((text == undefined) || (text == null))  {
    return '';
  }
  text = String(text);
  length = Number(length);
  if(text.length > length){
    text = text.substr(0, length)+" ...";
  }
  return text;
}
