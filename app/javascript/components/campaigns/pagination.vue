<template>
  <ul :class="containerClass">
    <li :class="pageClass">
      <a @click="prevPage()">
        <font-awesome-icon icon="caret-left" />
      </a>
    </li>
    <!-- range of pages -->
    <li
      v-for="(page, index) in pages"
      :class="[pageClass, page.isSelected ? 'active' : '']"
      :key="index"
    >
      <a v-if="page.breakView">{{ breakViewText }}</a>
      <a v-else @click="goToPage(page.index)">
        {{ page.content }}
      </a>
    </li>
    <li :class="pageClass">
      <a @click="nextPage()">
        <font-awesome-icon icon="caret-right" />
      </a>
    </li>
  </ul>
</template>
<script type="text/javascript">
export default {
  name: "CustomePagination",
  props: {
    value: {
      type: Number,
    },
    pageRange: {
      type: Number,
      default: 5,
    },
    totalPage: {
      type: Number,
      required: true,
    },
    containerClass: {
      type: String,
      default: "pagination-ul",
    },
    pageClass: {
      type: String,
      default: "page-item",
    },
    breakViewText: {
      type: String,
      default: "...",
    },
  },
	created() {
		const { value, totalPage } = this;
    if (totalPage < 1) return;
		if (value > totalPage) this.directToPage(totalPage);
		if (value < 1) this.directToPage(1);
	},
	data() {
		return {
			displayPage: this.value
		}
	},
  computed: {
    pages() {
      let renderedPaging = [];
			const {displayPage, pageRange, totalPage} = this;

			let range = (pageRange - 1)/2;
			for (let i = displayPage - range; i <= (displayPage + range); i++) {
				if (i > 0 && i <= totalPage) renderedPaging.push({ index: i, content: i, isSelected: i == displayPage });
			}
      if (renderedPaging.length > 0) {
        if (renderedPaging[0].index !== 1) {
          renderedPaging.unshift({ breakView: true });
          renderedPaging.unshift({ index: 1, content: 1, isSelected: false });
        }
        if (renderedPaging.at(-1).index !== totalPage) {
          renderedPaging.push({ breakView: true });
          renderedPaging.push({ index: totalPage, content: totalPage, isSelected: false });
        }
      } else {
        renderedPaging.push({ index: 1, content: 1, isSelected: true });
      }

      return renderedPaging;
    },
  },
  methods: {
    goToPage(page) {
			if (page < 1 || page > this.totalPage || this.displayPage === page) return;
      this.directToPage(page);
    },
		prevPage() {
      this.goToPage(this.displayPage - 1);
    },
    nextPage() {
      this.goToPage(this.displayPage + 1);
    },
		directToPage(page) {
      let url = new URL(window.location.href);
      url.searchParams.set("page", page);
			Turbolinks.visit(url.href);
		}
  },
};
</script>
<style type="text/css" scoped>
a {
  cursor: pointer;
}
</style>
