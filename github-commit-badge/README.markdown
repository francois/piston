Github Commit Badge
-------------------

This badge/banner can be used for displaying the latest (or a specific 
commit) for a github-project on your website.

<div><img src="http://hackvalue.de/heipei/wp-content/gallery/screenshots/github-commit-badge.png"></div>

It is implemented in JavaScript, therefore it is completely client-based.
Since this is the first time I've actually used JavaScript, the first 
time I actually wrote a CSS from scratch expect things to be buggy.

That said I'd be happy about ideas/patches. Look at the BUGS file or the 
TODO or come up with something own.

Usage
=====

To use it on your website you'll have to put this somewhere. This means the .js 
file as well as the .css and the lib/ and img/ directories. To adjust the
width of the whole thing look inside the style.css and set it for the 
container-class. I know that the way to define user/repos is still somewhat
cumbersome. The "branch" entry is optional, default is "master".

	<div id="github-commit-badge-container">
		<script type="text/javascript">
			var Badges = new Array();
			Badges[0] = new Object;
			Badges[0]["username"] = "heipei";
			Badges[0]["repo"] = "github-test";
			
			Badges[1] = new Object;
			Badges[1]["username"] = "heipei";
			Badges[1]["repo"] = "xmpp4r";
			Badges[1]["branch"] = "master";
			
		</script>
		<script type="text/javascript" src="github-commit-badge.js"></script>	
	</div>

If you want to use it on something like WordPress you'll have to put HTML
quotes around the content of the first script-block 
		<script type="text/javascript">
			<!--
				var Badges = new Array();
				[...]
				Badges[1]["branch"] = "master";
			-->
		</script>

Website
=======

[http://github.com/heipei/github-commit-badge/tree](http://github.com/heipei/github-commit-badge/tree) for now.
See a working demonstration at [http://hackvalue.de/~heipei/tmp/github-commit-badge/](http://hackvalue.de/~heipei/tmp/github-commit-badge/)

FAQ
===

Q: Why is it called a badge when it's really more of a banner?
A: Because I noticed that calling it banner increases the risk of it
	being filtered by AdBlock etc.

Q: Why does the JavaScript look like shit and is inconsistent?
A: Because I don't know a thing about JavaScript and the million
	things that can and do fail. That's why there might be some
	workarounds ;)

Q: What libs are used (and what for)?
A: jQuery for jQuery.getJSON and jQuery.each, datejs for
	Date.parse and md5 for md5_hex (for the gravatar).
	Also I learned a lot from DrNic's GitHub-badges [http://github.com/drnic/github-badges/tree](github-badges).
	
Author
======

Johannes 'heipei' Gilger <heipei@hackvalue.de>
