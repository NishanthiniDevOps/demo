<?php
Class dbObj{
  /* Database connection start */
        var $servername, $username, $password, $dbname, $port, $conn;

  public function __construct()
  {
    $this->servername = "";
    $this->username = "";
    $this->password = "";
    $this->dbname = "";
    $this->port = "5432";
  }
  function getConnstring() {
    $con = pg_connect("host=".$this->servername." port=".$this->port." dbname=".$this->dbname." user=".$this->username." password=".$this->password."") or die("Connection failed: ".pg_last_error());

    /* check connection */
    if (pg_last_error()) {
      printf("Connect failed: %s\n", pg_last_error());
      exit();
    } else {
      $this->conn = $con;
    }
    return $this->conn;
  }
}
?>
