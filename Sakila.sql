use sakila;

-- 1a. Display the first and last names of all actors from the table actor.

select first_name, last_name
  from actor
;

-- 1b. Display the first and last name of each actor in a single 
-- column in upper case letters. Name the column Actor Name.

select upper(concat(first_name, ' ', last_name)) as 'actor_name'
  from actor
;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only 
-- the first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name, last_name
  from actor
  where first_name = 'Joe' 
;

-- 2b. Find all actors whose last name contain the letters GEN

select actor_id, first_name, last_name
 from actor 
 where last_name like '%GEN%'
;

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by 
-- last name and first name, in that order:

select last_name, first_name
 from actor
 where last_name like '%LI%'
;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:

select country_id, country
 from country
 where country in 
  ('Afghanistan','Bangladesh','China')
 ;
 
 -- 3a. You want to keep a description of each actor. You don't think you will be performing queries on 
 -- a description, so create a column in the table actor named description and use the data 
 -- type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
 
alter table actor
 add description blob
 ;
 
 -- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
 -- Delete the description column.
 
 alter table actor 
  drop description
  ;
  
-- 4a. List the last names of actors, as well as how many actors have that last name, but only for names 
-- that are shared by at least two actors

select last_name, count(*) as same_last_name
 from actor a
 group by a.last_name
 having same_last_name >= 2
 ;
 
-- 4b. List last names of actors and the number of actors who have that last name, but 
-- only for names that are shared by at least two actors 

 select last_name, count(*) as count_same_lastname
 from actor a
 group by a.last_name
 having count_same_lastname >= 2
 ;
 
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as 
-- GROUCHO WILLIAMS. Write a query to fix the record.
 
 update actor
  set first_name = 'HARPO'
  where first_name = 'GROUCHO'
  and last_name = 'WILLIAMS'
;

-- Have to verify if change actually happened for 4c
select * from actor
 where first_name = 'HARPO'
 and last_name = 'WILLIAMS'
 ;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after 
-- all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

update actor
 set first_name = 'GROUCHO'
 where first_name = 'HARPO'
 and last_name = 'WILLIAMS'
;

-- Have to verity if changed back for 4d

select * from actor
 where first_name = 'GROUCHO'
 and last_name = 'WILLIAMS'
 ;
 
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

show create table address;

-- recreating address table from 'show create table address' line (copy and paste from there)

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
;
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

select s.first_name, s.last_name, a.address
 from staff s
 inner join address a
 on (s.address_id = a.address_id)
;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.

 select s.first_name, sum(p.amount) as total_rung_up_Aug
  from payment p 
  inner join staff s
  on (p.staff_id = s.staff_id)
  where p.payment_date between '2005-08-01' and '2005-08-31'
  group by p.staff_id
;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film.
--  Use inner join.

select f.title, count(fa.actor_id) as number_actors
 from film f
 inner join film_actor fa
 on (f.film_id = fa.film_id)
 group by f.title
;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select count(*) as total_copies
 from inventory 
 join film using (film_id)
 where title = 'HUNCHBACK IMPOSSIBLE'
;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

select sum(amount), first_name, last_name 
 from payment
 join customer 
 using (customer_id)
 group by (customer_id)
 order by (last_name)
;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended 
-- consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries 
-- to display the titles of movies starting with the letters K and Q whose language is English.


select title
from film
where language_id = (select language_id 
 from language
 where `name` ='English') and (title like 'k%' or title like 'q%')
;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select first_name, last_name
 from actor
 where actor_id in (select actor_id 
                     from film_actor
                     where film_id = (select film_id
                     from film 
					 where title = "Alone Trip"))
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the 
-- names and email addresses of all Canadian customers. Use joins to retrieve this information.

select first_name, last_name, email
 from country c
 join city  ci
 on (c.country_id = ci.country_id)
 join address a
 on (ci.city_id = a.city_id)
 join customer co
 on (a.address_id = co.address_id)
 where country = 'Canada'
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a 
-- promotion. Identify all movies categorized as family films.

select title 
 from category
 join film_category 
 using (category_id)
 join film
 using (film_id)
 where `name` = 'family'
 ;
 
 -- 7e. Display the most frequently rented movies in descending order.

select title
 from rental
 join inventory
 using (inventory_id)
 join film
 using (film_id)
 group by (film_id)
 order by count(rental_id) desc
 ;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select sum(amount), store_id
 from payment
 join staff 
 using (staff_id)
 group by (store_id)
;

-- 7g. Write a query to display for each store its store ID, city, and country.

select store_id, city, country 
 from store 
 join address 
 using (address_id)
 join city
 using (city_id)
 join country
 using (country_id)
;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the 
-- following tables: category, film_category, inventory, payment, and rental.)

select `name`
 from payment 
 join rental 
 using (rental_id)
 join inventory 
 using (inventory_id)
 join film_category 
 using (film_id)
 join category 
 using (category_id)
 group by category_id
 order by sum(amount) desc limit 5
;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by 
-- gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can 
-- substitute another query to create a view.

create view top_5_genres as 
 select `name`
 from payment 
 join rental 
 using (rental_id)
 join inventory 
 using (inventory_id)
 join film_category 
 using (film_id)
 join category 
 using (category_id)
 group by category_id
 order by sum(amount) desc limit 5
;

-- 8b. How would you display the view that you created in 8a?

select * from top_5_genres
;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view top_5_genres
;