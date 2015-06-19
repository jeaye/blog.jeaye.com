---
layout: index
title: Jeaye | Blog
---
<article>
  {% for post in site.posts %}
    <section>
      <div class="post_date">
        {{ post.date | date: "%B %d, %Y" }}
      </div>
      <h3>
        <a href="{{ post.url }}">{{ post.title }}</a>
      </h3>
      {{ post.excerpt }}
    </section>
  {% endfor %}
</article>
