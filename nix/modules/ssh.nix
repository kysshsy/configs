{
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  # This is the public half of the existing Mac SSH identity. GitHub deploy
  # keys remain separate and are added only when a private repository needs it.
  users.users.kyss.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCU0j5tiEhEYzbNikuzPmyWKAd9sYKSFzvdDE8npYpu8wR0/6L/TBmFtv/XvgQgO9NRzVtbCGMEku/ZWwfRBaRRCDMmbA3ZS7DkP2aHG14Q5GXKYShgY+l+q2fRnBu3Rbd13eANGRlkSZd64fBAHPdfrdRfZpPo0PfwFiNv5MffflZkWhyPSGC1eIelh/PEBlf5eVw9KyGgwtn0pbiHXvwOfxDr9Tgd8CME48gUK+vl59GaDCNowJapR9IYf2QZolrEsg7BGN8W9KcpSryAZWbQD6spgxNDYjXEWJuvS4yDw6ZttrSLe/XblgZdM9StAt+ATt00xaxX8yhBrxXyQ5hZpY/NQbLnelgUR0I2di8U28Od+cPyJ9MpLXLzCFiFh98pQPdUsj+uEFco49dQN4M62PY3INCbi8HjWc2cKwBCEm5RUjgqWASTaS0SwzbDza8cZ6yGpgEWbncTxysf7HcRVX14o77XD+m1DeqgGeQqhG5lMYadCxpPGhM0hDaxJJmj7RxpUGSYPM3WWh+vlQPfAf0dZzPXrI2LPVCtfRVQcAQ6JgvxvaypCSVIPZiU7cYcoGhxtUqTxaCdDtd4McBCMMWhOaizUe+plafoHcphQQX/4X2eHuko0k4LpKr/arVRNK/itaHJLGV3sndJ90mUPbqOSAHqFNHvVyp9le3mQw== kyss@192.168.0.106"
  ];
}
