---
layout: default
---
<ul>
  {% for post in site.posts %}
    <li>
      <div style="float: right;">
        <div>{{ post.date | date: "%B %d, %Y" }}</div>
      </div>
      <h3>
        <a href="{{ post.url }}">{{ post.title }}</a>
      </h3>
      {{ post.excerpt }}
    </li>
  {% endfor %}
</ul>
