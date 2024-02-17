# MLM 

This is a comprehensive open-source Multi-Level Marketing (MLM) package. It offers features such as registration, membership management, compensation structures, automated tasks, shopping capabilities, ticketing systems, and backend administration. The package includes four built-in bonus plans: unilevel, team, pairing, and affiliate rewards. Developers can easily extend these to include other customized bonus plans.

The software is built on [Genelet](https://github.com/genelet/perl) (or the [main site](http://www.genelet.com)), an open-source web development framework designed for creating secure, scalable, and high-performance websites.

##

## Chapter 1. INSTALLTION

The software is developed using the Perl programming language. It can operate as a standard CGI-BIN program or Fast CGI (refer to section 1.11 for more details). In addition to running CGI, you need to access the MySQL database and execute commands under the shell, if you want to run built-in unit and functional testing suites. You should pass these tests to ensure successful installation and accurate compensation calculations.

### 1.1) Download Perl Package _Genelet_
```
$ git clone https://github.com/genelet/perl.git
```
Assume your current directory is named *SAMPLE_home*. After cloning, a new directory named *perl* will be created within *SAMPLE_home*.

Please note that in a real environment, the home directory will not be named *SAMPLE_home*. Therefore, you should replace all mentions of *SAMPLE_home* in the instructions below with the name of your actual home directory.

### 1.2) Download _mlm_
```
$ git clone https://github.com/genelet/mlm.git
```
After the clone, directory _mlm_ will be created with 4 sub directories: *lib*, *conf*, *www* and *views*. The file structure will look like this:

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

Please have your web server to assign website's document_root to be *www*. You should also assign both *SAMPLE_home/perl* and *SAMPLE_home/mlm/lib* to be in the Perl path:
```
$ export PERL5LIB=/SAMPLE_home/perl:/SAMPLE_home/mlm/lib
```
_Genelet_ and _mlm_ use only basic 3rd-party modules, which your server may already have. Here is the list of the modules and the corresponding packages in Ubuntu:
```
Test::Class               sudo apt-get install libtest-class-perl
Digest::HMAC_SHA1         sudo apt-get install libdigest-hmac-perl
JSON                      sudo apt-get install libjson-perl
XML::LibXML               sudo apt-get install libxml-libxml-perl
Template                  sudo apt-get install libtemplate-perl
CGI::Fast (optional)      sudo apt-get install libcgi-fast-perl
```

### 1.4) Create MySQL Database

Create a MySQL database, and have username and password to access it. 

File *01_init.sql* in *conf* is the database schedma. You need to load it into the database using a client tool. After that, please follow *02_read.me* to add testing accounts and testing products which are defined in  *03_setup.sql*.

### 1.5) Build _config.json_ and _component.json_

Follow instruction in *04_read.me* to build your first config file, *config.json*. Put the database information you created in 1.4) in the *Db* block.

#### 1.5.1) Domain name in cookies

Note that authentication cookies' *Domain* should match exactly the website you are serving in *config.json*, otherwise it would report login error code 1036. For example, if your site uses no *www*, i.e. [http://noniland.com](http://noniland.com), then *Domain* should be _noniland.com_. If your site uses *www*, i.e. [http://www.noniland.com](http://www.noniland.com), then *Domain* should be _www.noniland.com_.

#### 1.5.2) Uploading in _component.json_

By default, uploading files will be saved in _Uploaddir_. You can override this behavior by assigning a specific folder in *component.json*. For example, the _Product_ photos are uploaded to *Document_root*/product as showing in *SAMPLE_home/mlm/lib/MLM/Gallery/component.json*:
```
  "insert"  :{"validate":["categoryid"],
    "upload":{
      "logoupload":["logo","/product"],
      "fullupload":["full","/product"]
    }
  }
```

#### 1.5.3) GET in _component.json_

For security reasons, Http *GET* method is allowed only for RESTful actions *topics*, *edit*, *delete* and *startnew*. If you create your own *action* (i.e. class' subroutine), and request it with *GET*, then please specifically add _"method":["GET"]_ to *component.json*.

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
$ cd SAMPLE_home
$ mkdir logs bin
$ cp conf/SAMPLE_bin/* bin/
(please change word 'SAMPE_home' to be yours in the files in 'bin/' ) 
$ cd bin
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

For most systems, running _mlm_ as a CGI program is both fast and secure. However, if you have a large customer base, limited system resources, or are operating in a virtual host environment, you might want to run it as a Fast CGI to gain extra speed. In particular, many virtual-host services run PHP under Apache's mod_fcgid module. You can simply modify the existing
```
$ SAMPLE_home/mlm/cgi-bin/goto
```
to be a Fast CGI **handler** in control panel. To do this, 
- copy *goto* to the home directory "/SAMPLE_home/mlm/www", and config your Apache to run it as a *Fcgid* handler.
- Modify *Script* in */SAMPLE_home/mlm/conf/config.json* to replace */cgi-bin/goto* by */goto* in *Script*.
- add digit 1 as the forth argument in function *Genelet::Dispatch::run* of _goto_. Explicitely:
```
Genelet::Dispatch::run("/SAMPLE_home/mlm/conf/config.json","/SAMPLE_home/mlm/lib",["Admin","Affiliate","Signup","Member","Sponsor","Placement","Category","Gallery","Package", "Packagedetail","Packagetype","Sale","Basket","Lineitem","Income","Incomeamount","Ledger","Tt","Ttpost","Week1","Week4","Affiliate"], 1);

```

##

## Chapter 2. COMPENSATION PLANS

We have internally developed four compensation plans. The parameters for these plans are defined in the *Custom* data block of *config.json*, as well as in three tables: *def_type*, *def_direct*, and *def_match*. 
You can use these as building blocks to create your own compensation plans.

### 2.1) Membership

Members who joint your MLM system are classified into different membership types, defined in *def_type*:
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

Note that signup is not the only type of shopping packages in your system. Customers who already have been joint as members, may shop your other products sporadically. This retail shopping will be assigned with *typeid* of value *SHOP_typeid* defined in *config.json*. 

### 2.2) Unilevel Bonus (or Direct Bonus)

Every time, when an existing member refers a new member to join the MLM system, she will be rewarded with *Unilevel Bonus*. She is called _sponsor_, and the new member her _offspring_. The dollar amount of the bonus is defined in table *def_direct*, which enables you to define privileges for various membership types
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
in which *directid* is the unique ID; *typeid* sponsor's *typeid*, and *who* offspring's *typeid*. *bonus* is the dollar amount rewarded to the sponsor.

The unilevel bonus is calculated every 4 weeks, or _monthly_, on days defined in the *cron_4week* table.

### 2.3) Team Bonus (or Match Bonus)

In addition to the unilevel bonus earned from directly referring a new member, sponsors can also earn a *Match-Up Bonus* from their referrals' activities. For example, if your direct referral sponsors a new member, you, as the 2nd-generation sponsor, receive a 2nd generation match-up bonus. This can extend to many generations.

At the same time, when a sponsor earns a match-up bonus, all of their direct referrals share an additional percentage of the bonus issued by the system. This is known as the *Match-Down Bonus*. In our system, we combine these two types of bonuses into a *Team Bonus* because it encourages individuals to build their sales teams.

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

Another popular type of MLM bonus is the pyramid bonus. In addition to the *sponsor* tree, a member can add another member, known as a _downline_, to their *pyramid* tree. 
This starts with two direct downlines on their left and right legs. Each leg can only have one downline. As you can imagine, this creates a private pyramid for each member.

We use the terms *sponsor* and *offspring* in the sponsorship tree, and *upline* and *downline* in the pyramid tree.

Downlines in one's pyramid tree are offsprings of their **direct sponsor and up-generation sponsors** in the sponsor tree (up to the first sponsor in the MLM system). 
This means that any of their up-generation sponsors can place a downline on their left or right leg. Thus, the up-generation sponsor (in the sponsor tree) becomes the new downline's up-generation upline (in the pyramid tree).

For instance, suppose Mary refers a new member, Karl, to the MLM system. 
Since Mary's two legs are already filled in the pyramid tree, 
she places Karl under John's left leg, who is a multi-generation offspring of Mary. Therefore, Karl is:
- Mary's direct offspring in the sponsorship tree;
- John's direct downline in the pyramid tree;
- Mary's multi-generation downline in the pyramid tree;
- John and Karl have no relationship in the sponsorship tree.




The pairing bonus is calculated weekly on days defined in *cron_1week*.

If a member accumulates enough points on both legs, they will be paired and cleared, sometimes referred to as a *collision*, and a pairing bonus will be generated. The parameters for this process are defined in *Custom->{BIN}* in *config.json*: *unit* is the base unit in *bv*, and *rate* is the rate used to convert BV to a dollar amount. For example, if a member has 500 bv on the left leg and 400 bv on the right leg, and *unit=200*, the collision will involve 2 units, which is then converted to *$40* (*rate=0.1*) as a dollar amount. After the clearing, the member's left leg has 100 bv and the right leg has 0 bv. 

Note that if *c_upper=30* is defined in *def_type*, the actual compensation the member receives will be *$30* instead of *$40*.

In practice, members often have very unbalanced sales volumes on their two legs. Therefore, our system implements a *2:1* type of pairing to clear one's points as quickly as possible. Whether a membership can execute *2:1* is defined in *def_type* as a privilege. For example, if a member has 1,000 bv on the left and 400 bv on the right, our system will pair at *800:400*, or 2 units of *2:1*, instead of 2 units of *400:400*. After the pairing, the member's points are *200:0*. *rate21* is the rate for this type of pairing.

The pairing bonus is calculated weekly on the days defined in *cron_1week*.


### 2.5) Auto Placement and Power Line

On the member portal, one can assign an offspring and a leg as the default upline for new signups in the pyramid tree. This is known as *Auto Placement*. If the assigned leg is already occupied by a new signup, the same leg of the new signup will automatically be used as the new default placement.

For example, if Mary assigns John's left leg as her *Auto Placement* and Henry joins, occupying John's left leg, Henry's left leg will become the new *Auto Placement* for Mary. This will continue until Mary explicitly changes the rule on her member portal. This feature helps to build one's *power line* automatically.

In practice, most members will try to leverage the power line of a strong upline, focusing on building up their other lines. Members should adjust their *Auto Placement* to optimize the balance of sales volumes between the two lines.

### 2.6) Affiliate Bonus

This type of bonus is typically applied to privileged members within your system. The ability for a member to become an affiliate is managed in the admin portal's *Membership/Affiliates* section.

During the process of activating a new signup application, your manager can attribute the signup to an affiliate. The dollar amount the affiliate receives is defined in *Custom->{RATE_affiliate}*. For example, if the new signup purchases a package worth *$1000* and the rate is *0.02*, the system will reward *$20* to the affiliate.

The affiliate bonus is calculated weekly on the days defined in *cron_1week*.


### 2.7) When to Calculate

All bonus calculations are automatically handled by the daily cron job program, *run_daily.pl*. Please refer to section 1.9 for more details.


### 2.8) Limited Displays

For securit reasons, you may limit the views of one's pyramid downlines and sponsorship offsprings to certain levels.  These are defined  in *config.json*:
- *MAX_plevel*, maximal display level for downlines on admin portal
- *MAX_mplevel*, maximal display level for downlines on member portal
- *MAX_slevel*, maximal display level for offsprings on admin portal
- *MAX_mslevel*, maximal display level for offsprings on member portal


##

## Chapter 3. MANAGEMENT AND ACCOUNTING

In this chapter, we explain how to use the backend management system to build product packages, process orders, and maintain ledger books, among other tasks. Please note that *MLM* **does not** handle credit/debit card charges or process online money transactions. Instead, it relies on your accounting department to **insert markers into the relevant sales and ledger tables** to proceed. 

You can either process payments offline (and insert markers in tables) or implement your own online credit card processing. For the latter solution, there are many other software options available.

*MLM* is not designed to be a comprehensive eCommerce package, so it only implements limited product and shopping-and-handling features. However, these are sufficient to run the core MLM functions. You can integrate a third-party eCommerce software with this *MLM* by coordinating the tables.

### 3.1) New Applicants

#### 3.1.1) On public website

On the public signup page, a new candidate fills in the application form and submits it to your system:

```
http://SAMPLE_domain/cgi-bin/goto/p/en/member?action=startnew
```
On this page, the applicant can specify their sponsor's username. In practice, the sponsor should provide a specific URL to candidates with their username automatically filled in.

Method 1, add the sponsor's username as an additional query:
```
http://SAMPLE_domain/cgi-bin/goto/p/en/member?action=startnew&sidlongin=MeMeMe
```

Method 2, put the username as a sub-domain or in the URL path, and let the web server redirect:
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
You need to use the *Redirect* functions of your web server to set up the above methods.  

Meanwhile, the new applicant, with the help of the sponsor, may also specify their pyramid upline by filling in the upline's member ID and leg. This is optional. We have implemented a rule for *auto pyramid placement*. Please see section 4.5).

#### 3.1.2) Backend

On the backend, new applicants are listed in *Membership/New Signups*. The manager can activate or delete these. If activating, the backend manager working on this page should input a transaction ID to track the source of the money. Meanwhile, our system will record the time and manager's name in the *member_signup* table.

Again, *mlm* does not process real transactions. It depends on your manager to input markers to proceed.

After the signup is activated, the new member will fully engage in all compensation plans. (Because the payment is completed.)

### 3.2) Process Sales Orders

At the same time, a new *Pending Order* is generated in *Sales*, indicating that you have charged the new member but need to package and ship the order.

After your warehouse has packaged the order, you should return to this page to change the order status to *Processing*, indicating that the order is now in your shipping department. 

The final step is to change the status to "Delivered", which means the product has been delivered. Input a tracking ID here.

You may implement your own logistic or ERP software system to track orders.

### 3.3) Online Shopping

Just like sales orders, we provide only a limited shopping function. You may enhance it, or implement another eCommerce package.

#### 3.3.1) category

Products are grouped into different categories by nature. Go to *Product/Categories* to manage categories, e.g., to create a new category.

#### 3.3.2) item

Then go to *Product/Product Items* to manage physical product items. For example, you can create a new item with price, BV, description, thumbnail, and full image, etc. 

#### 3.3.3) product package

In many cases, such as the initial signup, you may sell products in *Packages*. A pre-defined package consists of fixed items with a discounted price. Go to *Product/Packages* to create a new empty package by specifying its name and membership type. Then fill it in with real items. The total price of a package does not have to be the sum of the included items because of the discount.

For the initial signup package, the system will always use the **intrinsic price** defined in *def_type* to calculate the BV. That is, the BV will be fixed for a specific membership, regardless of the package's sales price. You may adjust the package's items and discount price at any time, but the BV must remain the same for the compensation calculation.

#### 3.3.4) retail shopping

Members can shop for individual items on the member portal:
```
     http://SAMPLE_domain/cgi-bin/goto/m/en/member?action=dashboard
```

Clicking on *Shop* at the top navigates the member to the shopping mall. They can only use their funds in the ledger book to purchase products. If the balance is insufficient, they should send money to your company through offline methods, which will then be added to the ledger.

### 3.4) Compensation and Ledgerbooks

Every week, *MLM* generates reward bonuses for members. Navigate to the backend's *Compensations* to find detailed calculations for all types of bonuses.

The *Details* and *Rewards* for each compensation type are straightforward. For instance, in *Direct Bonus*, we list the number of sales, grouped by membership types, made by *sponsors* within a week. In *Direct Reward*, we display the actual *unilevel* dollar amounts these sales have been converted to.

### 3.5) Ledgerbook

The final step in compensation calculations is to deposit the dollar amounts into the ledger book *income_ledger*. The funds will be split into two banks: one (*balance*) for withdrawal and the other (*shop_balance*) for retail shopping. *RATE_shop* in *config.json* is the percentage allocated for retail shopping (and so *1 - RATE_shop* for withdrawal). 

The weekly and monthly compensations are marked as *Weekly* and *Monthly* types, the shopping fee as *Shopping*, and the money withdrawal as *Withdraw* in the ledger book. Additionally, *In* is for members to deposit offline money. 

### 3.6) Cut-Off or Re-Join the Pyramid

Occasionally, you may need to disconnect a member from their upline's left or right leg in the pyramid tree. Later, you may re-join the small, separated tree to a different member. These operations can be performed in *Membership/Binary Tree* on the backend. (Internally, a cut pyramid is actually placed under a disabled system account *TOP_memberid* in *config.json*.)

### 3.7) Manage Managers

Backend managers who can log in to the backend admin portal are classified into four groups. The *ROOT* group can manage everything, including other managers. The other three groups are *ACCOUNTING*, *SUPPORT*, and *MARKETING*, who can perform selected sets of tasks. 

### 3.8) Compensation Tests

The *Compensation Test* allows managers to calculate different bonuses. These are harmless actions since they only display what the bonus would be, they don't actually deposit the funds into the bonus tables and ledger.

If you are a *ROOT* user, you can view and run *Execute and Write*, which actually runs the entire bonus calculation process! Normally, this should be avoided, since the executions are irreversible. However, during the early development phases, you may need it for bonus testing.

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












