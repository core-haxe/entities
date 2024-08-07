package cases.books;

import promises.PromiseUtils;
import promises.Promise;

class DBCreator extends DBCreatorBase {
    public function new() {
        super();
        sqliteFilename = "books.db";
    }

    public override function resetEntities() {
        super.resetEntities();
        @:privateAccess Author._checkedTables = false;
        @:privateAccess Book._checkedTables = false;
        @:privateAccess Category._checkedTables = false;
        @:privateAccess Publisher._checkedTables = false;
    }

    public override function createDummyData() {
        return new Promise((resolve, reject) -> {
            var list:Array<() -> promises.Promise<Any>> = [];

            var Marijn_Haverbeke = author("Marijn", "Haverbeke");
            var Nicolas_Bevacqua = author("Nicolás", "Bevacqua");
            var Nicholas_Zakas = author("Nicholas", "Zakas");
            var Axel_Rauschmayer = author("Axel", "Rauschmayer");
            var Addy_Osmani = author("Addy", "Osmani");
            var Kyle_Simpson = author("Kyle", "Simpson");
            var Scott_Chacon = author("Scott", "Chacon");
            var Ben_Straub = author("Ben", "Straub");
            var Caitlin_Sadowski = author("Caitlin", "Sadowski");
            var Thomas_Zimmermann = author("Thomas", "Zimmermann");

            var No_Starch_Press = publisher("No Starch Press");
            var O_Reilly_Media = publisher("O'Reilly Media");
            var Independently_published = publisher("Independently published");
            var Apress = publisher("Apress");

            var JavaScript = category("JavaScript");
            var Git = category("Git");
            var Software_Engineering = category("Software Engineering");

            var Eloquent_JavaScript = book("9781593279509", "Eloquent JavaScript, Third Edition", "A Modern Introduction to Programming", [Marijn_Haverbeke], "2018-12-04T00:00:00.000Z", No_Starch_Press, 472, [JavaScript, Software_Engineering], "JavaScript lies at the heart of almost every modern web application, from social apps like Twitter to browser-based game frameworks like Phaser and Babylon. Though simple for beginners to pick up and play with, JavaScript is a flexible, complex language that you can use to build full-scale applications.");
            var Practical_Modern_JavaScript = book("9781491943533", "Practical Modern JavaScript", "Dive into ES6 and the Future of JavaScript", [Nicolas_Bevacqua], "2017-07-16T00:00:00.000Z", O_Reilly_Media, 334, [JavaScript, Software_Engineering], "To get the most out of modern JavaScript, you need learn the latest features of its parent specification, ECMAScript 6 (ES6). This book provides a highly practical look at ES6, without getting lost in the specification or its implementation details.");
            var Understanding_ECMAScript_6 = book("9781593277574", "Understanding ECMAScript 6", "The Definitive Guide for JavaScript Developers", [Nicholas_Zakas], "2016-09-03T00:00:00.000Z", No_Starch_Press, 352, [JavaScript, Software_Engineering], "ECMAScript 6 represents the biggest update to the core of JavaScript in the history of the language. In Understanding ECMAScript 6, expert developer Nicholas C. Zakas provides a complete guide to the object types, syntax, and other exciting changes that ECMAScript 6 brings to JavaScript.");
            var Speaking_JavaScript = book("9781449365035", "Speaking JavaScript", "An In-Depth Guide for Programmers", [Axel_Rauschmayer], "2014-04-08T00:00:00.000Z", O_Reilly_Media, 460, [JavaScript, Software_Engineering], "Like it or not, JavaScript is everywhere these days -from browser to server to mobile- and now you, too, need to learn the language or dive deeper than you have. This concise book guides you into and through JavaScript, written by a veteran programmer who once found himself in the same position.");
            var Learning_JavaScript_Design_Patterns = book("9781449331818", "Learning JavaScript Design Patterns", "A JavaScript and jQuery Developer's Guide", [Addy_Osmani], "2012-08-30T00:00:00.000Z", O_Reilly_Media, 254, [JavaScript, Software_Engineering], "With Learning JavaScript Design Patterns, you'll learn how to write beautiful, structured, and maintainable JavaScript by applying classical and modern design patterns to the language. If you want to keep your code efficient, more manageable, and up-to-date with the latest best practices, this book is for you.");
            var You_Dont_Know_JS_Yet = book("9798602477429", "You Don't Know JS Yet", "Get Started", [Kyle_Simpson], "2020-01-28T00:00:00.000Z", Independently_published, 143, [JavaScript, Software_Engineering], "The worldwide best selling You Don't Know JS book series is back for a 2nd edition: You Don't Know JS Yet. All 6 books are brand new, rewritten to cover all sides of JS for 2020 and beyond.");
            var Pro_Git = book("9781484200766", "Pro Git", "Everything you neeed to know about Git", [Scott_Chacon, Ben_Straub], "2014-11-18T00:00:00.000Z", Apress, 458, [Git], "Pro Git (Second Edition) is your fully-updated guide to Git and its usage in the modern world. Git has come a long way since it was first developed by Linus Torvalds for Linux kernel development. It has taken the open source world by storm since its inception in 2005, and this book teaches you how to use it like a pro.");
            var Rethinking_Productivity_in_Software_Engineering = book("9781484242216", "Rethinking Productivity in Software Engineering", null, [Caitlin_Sadowski, Thomas_Zimmermann], "2019-05-11T00:00:00.000Z", Apress, 310, [Software_Engineering], "Get the most out of this foundational reference and improve the productivity of your software teams. This open access book collects the wisdom of the 2017 \"Dagstuhl\" seminar on productivity in software engineering, a meeting of community leaders, who came together with the goal of rethinking traditional definitions and measures of productivity.");

            list.push(Marijn_Haverbeke.add);
            list.push(Nicolas_Bevacqua.add);
            list.push(Nicholas_Zakas.add);
            list.push(Axel_Rauschmayer.add);
            list.push(Addy_Osmani.add);
            list.push(Kyle_Simpson.add);
            list.push(Scott_Chacon.add);
            list.push(Ben_Straub.add);
            list.push(Caitlin_Sadowski.add);
            list.push(Thomas_Zimmermann.add);

            list.push(No_Starch_Press.add);
            list.push(O_Reilly_Media.add);
            list.push(Independently_published.add);
            list.push(Apress.add);

            list.push(JavaScript.add);
            list.push(Git.add);
            list.push(Software_Engineering.add);

            list.push(Eloquent_JavaScript.add);
            list.push(Practical_Modern_JavaScript.add);
            list.push(Understanding_ECMAScript_6.add);
            list.push(Speaking_JavaScript.add);
            list.push(Learning_JavaScript_Design_Patterns.add);
            list.push(You_Dont_Know_JS_Yet.add);
            list.push(Pro_Git.add);
            list.push(Rethinking_Productivity_in_Software_Engineering.add);

            PromiseUtils.runSequentially(list).then(result -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }

    public function author(firstName:String, lastName:String):Author {
        var author = new Author();
        author.firstName = firstName;
        author.lastName = lastName;
        return author;
    }

    public function publisher(name:String):Publisher {
        var publisher = new Publisher();
        publisher.name = name;
        return publisher;
    }

    public function category(name:String):Category {
        var category = new Category();
        category.name = name;
        return category;
    }

    public function book(isbn:String, title:String, subTitle:String, authors:Array<Author>, published:String, publisher:Publisher, pages:Int, categories:Array<Category>, description:String):Book {
        var book = new Book();
        book.isbn = isbn;
        book.title = title;
        book.subTitle = subTitle;
        book.authors = authors;
        book.published = published;
        book.publisher = publisher;
        book.pages = pages;
        book.categories = categories;
        book.description = description;
        return book;
    }
}