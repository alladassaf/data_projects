USE my_projects;

CREATE TABLE youtube_stats (
	ID INT NOT NULL,
    title TEXT NOT NULL,
    video_ID TEXT NOT NULL,
    published_at TEXT NOT NULL,
    keyword TEXT NOT NULL,
    likes BIGINT NOT NULL,
    comments BIGINT NOT NULL,
    views BIGINT NOT NULL
);


SELECT * FROM youtube_stats;

CREATE TABLE comments (
	ID INT NOT NULL,
    video_ID VARCHAR(500) NOT NULL,
    Comments TEXT NOT NULL,
    likes BIGINT NOT NULL,
    sentiment INT NOT NULL
);


SELECT
	y.ID,
    y.title,
    y.video_ID,
    c.video_ID,
    c.comments,
    c.sentiment
FROM
	youtube_stats y
RIGHT JOIN
	comments c
    USING(video_ID)
LIMIT 20;



-- 1) What are the top 3 ranked commented-upon videos in the dataset?

WITH cte AS
(SELECT
	*,
    DENSE_RANK() OVER(ORDER BY count_of_comments DESC) 'comment_rank'
FROM
	(SELECT
		y.title,
		y.video_ID,
		COUNT(c.comments)  'count_of_comments'
	FROM
		youtube_stats y
	JOIN
		comments c
		USING(video_ID)
	GROUP BY
		y.video_ID) x)
SELECT
	*
FROM
	cte
WHERE comment_rank <=3;


-- 2)  What are the top 3 ranked total liked on comments per videos in the dataset?

WITH cte AS
	(SELECT
		*,
		DENSE_RANK() OVER(ORDER BY count_of_likes DESC) 'likes_rank'
	FROM
		(
			SELECT
				y.title,
                c.comments,
				y.video_id,
				SUM(c.likes) 'count_of_likes'
			FROM
				youtube_stats y
				JOIN
				comments c
				USING(video_ID)
			GROUP BY
				y.video_ID
		) x)
SELECT
	*
FROM
	cte
WHERE
	likes_rank <= 3;
    
    
-- 3) How many total views does each category have?


SELECT
	keyword,
    SUM(views) 'total_views'
FROM
	youtube_stats
GROUP BY
	keyword;
    
    
-- 4) How many total likes does each category have?

SELECT
	keyword,
    FORMAT(SUM(likes), 'C') 'total_views'
FROM
	youtube_stats
GROUP BY
	keyword;
    
    
    
-- 5) What are the most-liked comment per video?

WITH cte AS (SELECT
	y.title,
	c.comments,
    c.likes,
    DENSE_RANK() OVER(PARTITION BY y.video_ID ORDER BY likes DESC) 'likes_ranking'
FROM
	youtube_stats y
JOIN
	comments c
    USING(video_ID))
SELECT
	*
FROM
	cte
WHERE 
	likes_ranking = 1;
    
-- 6) What is the ratio of views/likes per video?

SELECT
	title,
	ROUND(views / likes, 1) AS 'views-to-likes-ratio'
FROM
	youtube_stats;
    
    
-- 7)  What is the ratio of views/likes per category ordered by ratio descending?

SELECT
	keyword,
    ROUND(SUM(views) / SUM(likes), 1) 'views-to-likes-ratio'
FROM
	youtube_stats
GROUP BY
	keyword
ORDER BY
	2 DESC;
    
    
-- 8) What is the average sentiment score in each keyword category?

SELECT
	y.keyword,
    ROUND(AVG(c.sentiment), 2) 'avg_sentiment'
FROM
	youtube_stats y
    JOIN
    comments c
    USING(video_ID)
GROUP BY
	1;
    
    
-- 9) How many times do company names (i.e., Apple or Samsung) appear in each keyword category?

WITH cte AS
(SELECT
	keyword
FROM
	youtube_stats
WHERE
	keyword IN ('Apple', 'cnn', 'xbox', 'nintendo', 'marvel'))
SELECT
	keyword,
    COUNT(keyword) 'count_of_videos'
FROM
	cte
GROUP BY
	keyword
ORDER BY
	2 DESC;
	
	

