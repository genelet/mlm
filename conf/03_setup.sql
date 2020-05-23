INSERT INTO def_type (typeid,short,name,bv,price,yes21,c_upper)
VALUES (1,'Distributor','Distributor Level Member',100,1000,'No',10000),
       (2,'Sub-Distributor',    'Sub-Distributor Level Member',     10, 600,'No',10000),
       (3,'Customer',  'Customer',   0, 400, 'No',10000);
INSERT INTO def_direct (directid,typeid,whoid,bonus)
VALUES ( 1,1,1,500),( 2,1,2,300),( 3,1,3,200),( 4,1,4,100),( 5,1,5,0),
       ( 6,2,1,400),( 7,2,2,200),( 8,2,3,100),( 9,2,4, 50),(10,2,5,0),
       (11,3,1,300),(12,3,2,100),(13,3,3, 50),(14,3,4, 50),(15,3,5,0),
       (16,4,1,200),(17,4,2, 50),(18,4,3, 50),(19,4,4, 50),(20,4,5,0),
       (21,5,1,100),(22,5,2, 50),(23,5,3, 50),(24,5,4, 50),(25,5,5,0);
INSERT INTO def_match (matchid, typeid, lev, rate)
VALUES ( 1,1, 2,.02),( 2,1, 3,.01),( 3,1, 4,.01),( 4,1, 5,.01),( 5,1, 6,.01),
       ( 6,1, 7,.01),( 7,1, 8,.01),( 8,1, 9,.01),( 9,1,10,.01),
       (10,2, 2,.02),(11,2, 3,.01),(12,2, 4,.01),(13,2, 5,.01),(14,2, 6,.01),
       (15,2, 7,.01),(16,2, 8,.01),
       (17,3, 2,.02),(18,3, 3,.01),(19,3, 4,.01),(20,3, 5,.01),(21,3, 6,.01),
       (22,4, 2,.02),(23,4, 3,.01),(24,4, 4,.01);

INSERT INTO admin (adminid,login,passwd,created)
VALUES ("ROOT",'gmarket',SHA1(CONCAT('gmarket','gmarketIsCool')),NOW());
INSERT INTO member (memberid,login,passwd,active,typeid,email,sid,pid,top,leg,
milel,miler,firstname,lastname,defpid,defleg,countl,countr,signuptime,created)
VALUES (888,'www',SHA1(CONCAT('www','gmarketCool')),'Yes',1,'noname@noplace.cm',
 1, 1, 1, 'L', 0, 0, 'Default', 'Default', 888, 'L', 0, 0, NOW(), NOW());
INSERT INTO member_affiliate (memberid,created) VALUES (888,NOW());
