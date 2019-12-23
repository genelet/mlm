# MLM 

It is a fully featured open-source Multi-Level Market (MLM) package, providing registration, membership, compensations, cronjobs, shopping, ticketing, backend administration and so on. Four types of bonus plans are implemented internally: unilevel, team, pairing and affiliate rewards, but developer can easily extend it to other customized plans. 

The software is built on top of [Genelet](https://github.com/genelet/perl) (or the [main site](http://www.genelet.com)), which is a multilingual open-source web development framework for developing secure, scalable and high-performance web sites.

##

## Chapter 1. INSTALLTION

The software is written in Perl programming language. It can run as standard CGI-BIN program or Fast CGI (see section 1.11). Besides running CGI, you need to access MySQL database and run commands under shell. _MLM_ has built-in unit and functional testing suites, which you need to pass to make sure that installation is successful and compensation calculations are correct.

### 1.1) Download Perl Package _Genelet_
```
$ git clone https://github.com/genelet/perl.git
```
Assume your current directory is *SAMPLE_home*. After the clone, directory *perl* will be created within *SAMPLE_home*.

Note that in real environment, the home directory is definitely **not** named as _SAMPLE_home_ so you should replace all the mentions of *SAMPLE_home* below by yours.

### 1.2) Download _mlm_
```
$ git clone https://github.com/genelet/mlm.git
```
After the clone, directory _mlm_ will be created to contain 4 directories: *lib*, *conf*, *www* and *views*. The file structure will look like this:

```
SAMPLE_home /
            perl    /
                       Genelet
            mlm /
                       lib    /
                                  MLM
                       conf   /
                       www    /
                       views  /
```                     

### 1.3) Prepare Web Server

Have your web server to point website's document root to *www*. Optionally, you may assign both *SAMPLE_home/perl* and *SAMPLE_home/mlm/lib* to the Perl path:
```
$ export PERL5LIB=/SAMPLE_home/perl:/SAMPLE_home/mlm/lib
```
_Genelet_ and _mlm_ use only basic 3rd-party modules, which your server may already have. You may need to install the following modules. The corresponding packages in Ubuntu are marked too:
```
Test::Class               sudo apt-get install libtest-class-perl
Digest::HMAC_SHA1         sudo apt-get install libdigest-hmac-perl
JSON                      sudo apt-get install libjson-perl
XML::LibXML               sudo apt-get install libxml-libxml-perl
Template                  sudo apt-get install libtemplate-perl
CGI::Fast (optional)      sudo apt-get install libcgi-fast-perl
```

### 1.4) Create MySQL Database

Create a MySQL database, and username and password to access it. File *01_init.sql* in *conf* is the database schedma. You need to load it into the database using a client tool. After that, please follow *02_read.me* to add test accounts and test products defined in  *03_setup.sql*.

### 1.5) Build _config.json_

Follow instruction in *04_read.me* to build your first config file, *config.json*. Put the database information you created in 1.4) in the *"Db"* block.

### 1.6) Run Unit Tests

Follow instruction in *05_read.me* to add *Beacon.pm*, *admin.t* and *placement.t* to *lib/MLM*, *lib/MLM/Admin* and *lib/MLM/Placement*:
```
SAMPLE_home / mlm / lib / MLM
                                     / Beacon.pm
                                     / Admin
                                                 / admin.t
                                     / Placement
                                                 / placement.t
```
Then go to *Admin* and *Placement* to run _Unit_ tests:
```
$ cd SAMPLE_home
$ cd mlm/lib/MLM/Admin
$ perl admin.t
$ cd ../Placement
$ perl placement.t
```

### 1.7) Run Functional Tests

Follow instruction in *06_read.me* to create *bin* and associated files. You may create an empty director *SAMPLE_home/mlm/logs* for debugging messages before run the _Functional_ tests:
```
$ mkdir ../logs
$ cd ../bin/
$ perl 01_product.t
$ perl 02_member.t
$ perl 03_income.t
$ perl 04_ledger.t
$ perl 05_shopping.t
```

### 1.8) Build Week Tables

Follow instruction in *07_read.me* to build the _week_ tables *cron_1week* and *cron_4week*, on which days the different types of compensations will be calculated. To do this, run *08_weekly.pl* in *conf*:
```
$ perl 08_weekly.pl -h
```
And follow up the message to proceed. 

### 1.9) Build Cronjob

This is *run_daily.pl* in *bin*. You should edit it and run it as a daily cronjob e.g. 2am every day:
```
$ crontab -e
0 2 * * * SAMPLE_home/mlm/bin/run_daily.pl
```

### 1.10) Launch the Website!

Make sure the web server, the config file, the week tables and the cron job are all set up correctly. Now you are alive! Here are the entrance URLs:

New member signup:
```
     http://SAMPLE_domain/cgi-bin/goto/p/en/member?action=startnew
```

Backend admin:
```
     http://SAMPLE_domain/cgi-bin/goto/a/en/member?action=topics
```

Member portal:
```
     http://SAMPLE_domain/cgi-bin/goto/m/en/member?action=dashboard
```

### 1.11) Run as Fast CGI program

For most system, running _mlm_ as a CGI program is both fast and more secure. However, if you have a large customer base, a tight system resource or on a virtual host enrionment, you may want to run it as a Fast CGI to gain extra speed. In particular, many virtual-host services are running PHP under Apache's mod_fcgid module. So you may just modify the existing
```
$ SAMPLE_home/mlm/cgi-bin/goto
```
to be a Fast CGI **handler** in control panel. To do this, 
- copy *goto* to the home directory "/SAMPLE_home/www", and have your Apache to run it as a *Fcgid* handler.
- add digit 1 as the forth argument in _Genelet::Dispatch::run_ of _goto_. So it becomes:
```
Genelet::Dispatch::run("/SAMPLE_home/mlm/conf/config.json","/SAMPLE_home/mlm/lib",["Admin","Affiliate","Signup","Member","Sponsor","Placement","Category","Gallery","Package", "Packagedetail","Packagetype","Sale","Basket","Lineitem","Income","Incomeamount","Ledger","Tt","Ttpost","Week1","Week4","Affiliate"], 1);

```

##

## Chapter 2. COMPENSATION PLANS

We have internally built 4 compensation plans. The parameters in the plans are defined in the *Custom* data block of *config.json*, and 3 tables: *def_type*, *def_direct* and *def_match*. You may use them as basic blocks to build your own compensation plans. 

### 2.1) Membership

Members who joint your MLM system are classified into different types defined in *def_type*:
```
CREATE TABLE def_type (
  typeid tinyint(3) unsigned NOT NULL,
  short varchar(255) NOT NULL,
  name varchar(255) DEFAULT NULL,
  bv int(10) unsigned DEFAULT NULL,
  price int(10) unsigned DEFAULT NULL,
  yes21 enum('Yes','No') DEFAULT 'No',
  c_upper int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (typeid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```
in which *typeid* is the unique ID; *name* the membership name such as "Gold Membership"; *short* its abbreation; *price* the minimal price of this membership's initial sign-up package, and *bv* the _Bonus Value_ of the package. *yes21* and *c_upper* are put there for *Pairing* bonus only: *yes21* means whether or not the membership allows *2:1* type of pairing in additional to *1:1*, and *c_upper* the upper limit in dollar amount for each pairing.

Note that signup is not the only type of shopping packages in your system. Customers who already have joint as members, may shop your other products sporadically. This retail shopping will be assigned with *typeid* of value *SHOP_typeid* defined in *config.json*. 

### 2.2) Unilevel Bonus (or Direct Bonus)

Every time, when an existing member refers a new member to join your MLM system, she will be rewarded with *Unilevel Bonus*. She is called _sponsor_, and the new member her _offspring_. The dollar amount of the bonus is defined in table *def_direct*:
```
CREATE TABLE def_direct (
  directid tinyint(3) unsigned NOT NULL,
  typeid tinyint(3) unsigned NOT NULL,
  whoid tinyint(3) unsigned NOT NULL,
  bonus double DEFAULT NULL,
  PRIMARY KEY (directid),
  KEY typeid (typeid),
  KEY whoid (whoid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```
in which *directid* is the unique ID; *typeid* sponsor's *typeid*, and *who* offspring's *typeid*. *bonus* is the dollar amount rewarded to the sponsor. This table will allow you to define privileges for different membership types. 

The unilevel bonus is calculated every 4 weeks, or _monthly_, on days defined in the *cron_4week* table.

### 2.3) Team Bonus (or Match Bonus)

Besides referring new member directly, for who there is a unilevel bonus, sponsor gains referring bonus over generations called *Match-Up Bonus*. For example, if your direct offspring referes a new member, not only the offspring, who is rewarded the unilevel bonus, but also you as the 2nd-generation sponsor gains the 2nd generation match-up bonus. This can go up to many generations.

Meanwhile, just because one's sponsor gets match-up bonus, all of her direct offsprings will share additional percentage of the bonus issued by the system, which is called *Match-Down Bonus*. In our system, we put the two types of bonus together as *Team Bonus*, because it helps one build up her sales team.

The match-up bonus plan is defined in *def_match*:
```
 CREATE TABLE def_match (
  matchid tinyint(3) unsigned NOT NULL,
  typeid tinyint(3) unsigned NOT NULL,
  lev tinyint(3) unsigned NOT NULL,
  rate double NOT NULL DEFAULT '0',
  PRIMARY KEY (matchid),
  KEY typeid (typeid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```
in which *matchid* is the unique ID; *typeid* sponsor's *typeid*; *lev* the level of generations (apparently, it is 2 or above); and *rate* the percentage. For example, if *lev=10* and *rate=0.01*, then a newly joint offpsing with initial package *$1000* will trigger a reward of *$10* to her 10-up-generation sponsor.

The match-down rate is defined in *RATE_matchdown* in *config.json*. Assume that a sponsor has 5 direct offsprings. She gets *$10* in match-up bonus, and the match-down rate is *0.25*. So the system will assign *$0.5* to each of the offsprings as the match-down bonus. 

The team bonus is calculated weekly on days defined in *cron_1week*.

### 2.4) Pairing Bonus (or Binary Bonus)

It is another type of popular MLM bonus. Besides the above *sponsor* tree, member can place another member, called _downline_ to her *pyramid* tree, starting with two direct downlines on her left and right legs. Each leg can and only can have one downline. As you image, this builds up a private pyramid for each member. 

We use words *sponsor* and *offspring* in the sponsorship tree, and word *upline* and *downline* in the pyramid tree.

Downlines in one's pyramid tree, are offsprings of her **direct sponsor and up-generation sponsors** in the sponsor tree (till the first sponsor in the MLM system). This means, any of her up-generation sponsors can place a downline to her left or right leg. Thus, the up-generation sponsor (in the sponsor tree) becomes new downline's up-generation upline (in the pyramid tree).

Here is a typical example: a sponsor named Mary refers an offspring to the MLM system. Because Mary's two legs are already filled up so she places the offspring under a open leg of downline "John". The new member is 
- Mary's direct offspring, sponsorship tree
- John's direct downline, pyramid tree
- Mary's multi-generation downline, pyramid tree
- John and the new member have no relationship in the sponsorship tree.

In the pyramid tree, a newly joint downline will add his package's BV to **all up-generation uplines' relevant legs**. The BV values accumulated are called one's *points* or *sales volume*.

If one gets enough points on both the legs, they will be paired and flushed out, sometimes call *collission*, and then a paring bonus will be generated. *Custom->{BIN}* in *config.json* defines what these parameters are: *unit* is the base unit in *bv*, *rate* for rate to convert BV to dollar amount. For example, if someone has 500 bv on the left leg and 400 bv on the right leg, and *unit=200*, the collission will involve 2 units, which is then converted to *$40* (*rate=0.1*) as dollar amount. After the flushing, her left leg has 100 bv and right 0 bv. 

Note that if *c_upper=30* is defined in *def_type*, the real compensation she receives will be *$30* instead of *$40*.

In practice, members have very unbalanced sales volumes on two legs. So our system implements another *2:1* type of pairing so as to flush out one's points as fast as possible. Whether or not a membership can execute *2:1* is defined in *def_type* as a privilege. For example, if one has 1,000 bv on left and 400 bv on right, our system will pair at *800:400*, or 2 units of *2:1*, instead of 2 units of *400:400*. After the paring, her points are *200:0*. *rate21* is the rate for this type of pairing.

The pairing bonus is calculated weekly on days defined in *cron_1week*.


### 2.5) Auto Placement and Power Line

On member portal, one can assign an offspring and a leg, as the default upline for new signups in the pyramid tree. This is called *Auto Placement*. If the leg is already been occupied by a new signup, the same leg of the new signup will be used automatically as the new default placement.

For example, Mary assigns John's left leg as her *Auto Placement*. If Henry joins and occupies John's left leg, Henry's left leg will become the new *Auto Placement* for Mary, and so on, until Mary changes the rule explicitely on her member portal. This feature helps to build one's *power line* automatically.

In practice, most members will try to take advantage of powerful upline's power line, so they need only to build up the other lines. Member should adjust her *Auto Placement*, so as to optimize the balance of two sales volumes.


### 2.6) Affiliate Bonus

This type of bonus is usually applied to selected members in your system. Whether or not a member can become affiliate is managed in admin portal's *Membership/Affiliates*.

During the process to activate a new signup application, your manager can credit the signup to an affiliate. The dollar amount the affiliate gets is defined in *Custom->{RATE_affiliate}*. For example, if the new signup buys a package of *$1000* and the rate *0.02*, the system will reward *$20* to the affiliate.

The affiliate bonus is calculated weekly on days defined in *cron_1week*.


### 2.7) When to Calculate

All the bonus calculations are automatically managed by the daily cronjob program *run_daily.pl*. Please check section 1.9).


### 2.8) Limited Displays

For securit reasons, you may limit the views of one's pyramid downlines and sponsorship offsprings to certain levels.  These are defined  in *config.json*:
- *MAX_plevel*, maximal display level for downlines on admin portal
- *MAX_mplevel*, maximal display level for downlines on member portal
- *MAX_slevel*, maximal display level for offsprings on admin portal
- *MAX_mslevel*, maximal display level for offsprings on member portal


##

## Chapter 3. MANAGEMENT AND ACCOUNTING

In this chapter, we explain how to use the backend management system to build product packages, to process orders and to keep ledger books etc. Note that *MLM* **does not** actually charge credit/debt card nor process online money transaction. It depends on your accounting department to **put markers into relevant sales and ledger tables** to proceed. 

So either you process money offline (and put markers in tables), or you implement your own online credit card processing. For the later solution, we believe there are many other software available.

*MLM* is not aimed to be an eCommerce package too, so it impements only limited product and shopping-and-handling features. However, they are good enough to run the core MLM functions. You can combine a 3rd party eCommerce software with this *MLM*, by coordinating the tables.

### 3.1) New Applicants

#### 3.1.1) On public website

On the public signup page, new candidate fills in the application form and submits it to your system:
```
http://SAMPLE_domain/cgi-bin/goto/p/en/member?action=startnew
```
On this page, the applicant can specify his sponsor username. In practice, the sponsor should give a specific URL to candidates with her username being automatically filled in.

Method 1, put sponsor's username as an additional query:
```
http://SAMPLE_domain/cgi-bin/goto/p/en/member?action=startnew&sidlongin=MeMeMe
```

Method 2, put the username as sub-domain or in URL path, and let the web server to redirect:
```
http://MeMeMe.SAMPLE_domain/
```
or
```
http://SAMPLE_domain/MeMeMe
```
The system would redirect it to 
```
http://SAMPLE_domain/cgi-bin/goto/p/en/member?action=startnew&sidlongin=MeMeMe
```
You need to use *Redirect* functions of your web server to set the above methods up.  

Meanwhile, the new applicant, with the help of sponsor, may also specify his pyramid upline by filling in upline's member ID and leg. This is just an option. We have implemented an rule to do *auto pyramid placement*. Please see section 4.5).

#### 3.1.2) Backend

On backend, new applicants are listed in *Membership/New Signups*. Manager can activate it, or delete it. If activating, the backend manager who works on this page, should put a transaction ID so as to track where the money came from. Meanwhile, our system will record the time and manager's name in the *member_signup* table.

Again, *mlm* does not process real trasactions. It depends on your manager to put markers to proceed.

After the signup is activated, the new member will fully engage in all compensation plans. (Because the payment is completed.)

### 3.2) Process Sales Orders

At the same time, a new *Pending Order* is generated in *Sales*, meaning that you have charged the new member but need to package and ship the order.

After your warehouse has packaged the order, you should come to this page again, to turn the order status to *Processing*, meaning the order is now in your shipping department. 

The last step is to turn it into status "Delivered", which means the prouduct is delivered. Put a tracking ID here.

You may implement your own logistic or EPR software system to track orders.

### 3.3) Online Shopping

Just as sales orders, we provide only a limited shopping function. You may enhance it, or implement another eCommerce package.

#### 3.3.1) category

Products are grouped into different categories by natures. Go to *Product/Categories* to manage categories e.g. to create a new category.

#### 3.3.2) item

Then go to *Product/Produc Items* to manage physical product items. For example, you can create a new item with price, BV, description, thumbnail and full image etc. 

#### 3.3.3) product package

In many cases, such as the initial signup, you may sell products in *Packages*. A pre-defined package consists of fixed items with discount price. Go to *Product/Packages* to create a new empty package by specifying its name and membership type. Then fill it in with real items. The total price of a package does not have to be the sum of the included items because of discount.

For the initial signup package, the system will always use the **intrinsic price** defined in *def_type* to calculate the BV. I.e., the BV will be fixed for a specific membership, whatever package's sales price is. You may adjust package's items and discount price at any time, but the BV must be kept the same in the compensation calculation.

#### 3.3.4) retail shopping

Members can shop individual items on member portal:
```
     http://SAMPLE_domain/cgi-bin/goto/m/en/member?action=dashboard
```
Clicking on *Shop* on top will take the member to the shopping mall. She can only use her money in the ledger book to buy product. If there is no enough balance, she shoud send money to your company by an offline means, and have it to be added to the ledger. See below.

### 3.4) Compensation and Ledgerbooks

Every week, *MLM* generates reward bonuses for members. Go to backend's *Compensations* you will find all types of bonus calculations in details.

The explanations of *Details* and *Rewards* in each compensation type is straightforward. For example, in *Direct Bonus*, we list the numbers of sales, grouped by membership types, which *sponsors* have made within a week. In *Direct Reward*, we show actual *unilevel* dollar amounts these sales have been converted to.

### 3.5) Ledgerbook

The last step in compensation calculations is to put the dollar amounts into ledgerbook *income_ledger*. The dollars will be divided into two banks: one (*balance*) for withdraw and the other (*shop_balance*) for retail shopping. *RATE_shop* in *config.json* is the percentage for retail shopping (and so *1 - RATE_shop* for withdraw). 

The weekly and monthly compensations are marked as types *Weekly* and *Monthly*, the shopping fee as *Shopping*, and the money withdraw as *Withdraw* in the ledger book. In addition, *In* is for member to send in offline money. 

### 3.6) Cut-Off or Re-Join the Pyramid

Occassionally, you may cut a member off her upline's left or right leg in pyramid tree. Later, you may re-join the small, separated tree to a different member. You can do those operations in *Membership/Binary Tree* on backend. (Internally, a cutted pyramid is actually placed under a disabled system account *TOP_memberid* in *config.json*.)

### 3.7) Manage Managers

The backend managers who can login to the backend admin portal,are classified into 4 groups. The *ROOT* group can manage anything including other managers. The other three groups are *ACCOUNTING*, *SUPPORT*, and *MARKETING*, who can run selected sets of tasks. 

### 3.8) Compensation Tests

The *Compensation Test* allows managers to calculate different bonus. These are harmless actions since they only show you what bonus would be, they don't actually put the dollars into the bonus tables and leger.

If you are *ROOT*, you can view and run *Execute and Write*, which actually run the whole bonus calculation process! Nomarlly this should be avoided, since the executions are not revertable. However, during early development phases, you may need it for bonus testings.

##

## Chapter 4. OTHERS

### 4.1) Customization

For new development, developers may check out the [Tutorial](http://www.genelet.com/index.php/tutorial-perl/) and [Manual](http://www.genelet.com/index.php/2017/02/08/perl-development-manual/) of *Genelet*. It is a very powerful framework, yet has a short learning-curve.

If developers merely want to customize compensations, they should focus on programs in *lib/MLM/Income*. For example, to add a new compensation plan called *Bonus X*, what the minimal steps to do is like the followings:
- add new column *statusX* to database table *cron_1week*
- add new action name "*week1_x*" to the *actions* section in *lib/MLM/Income/component.json*
- add new plan's parameters to the *Custom* block in *config.json*
- write new methods *is_week1_x*, *week1_x*, *done_week1_x* and *weekly_x* in *lib/MLM/Income/Model.pm*
- add the bonus to methods *run_cron*, *run_daily* and *run_all_tests* of *Model.pm*
- add it to the daily cronjob *bin/run_daily.pl*.

### 4.2) Development in Java and GO Lang

*Genelet*, on which the framework this software is based, allows developers to write the same programs in Java and GO. Besides Perl, developers may code new programs in other program languages. Contact [us](mailto:genelet@gmail.com) for details.

### 4.3) CSS Bootstrap Template

Dynamical HTML pages are generated by Perl's *Template Toolkits* package using [Bootstrap](https://getbootstrap.com/), by which Developers can replace their own CSS and Javascript frameworks. *Genelet* follows the *Model/View/Controller* pattern, so developers only need to change the *Views*. To do this:
- Create a new view directory, and have string *Template*, currently *SAMPLE_home/mlm/views*, point to it in *config.json*.
- in the new directory, build the same file structure as the old one. You may simply:
```
$ (cd SAMPLE_home/views; tar cvf - *) | (cd NEW_view_directory; tar xvf -)
```
- make changes in template files as you like. Just in case, you may switch back to the original ones.

### 4.4) JSON API

Another useful feature of *Genelet* is to get the JSON response by changing the tag name *en* to *json* in the URL. This can be used as API for other development like mobile apps.












