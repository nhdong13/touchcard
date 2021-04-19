<template>
  <div class="dropdown">
    <button @click="isOpen = !isOpen" :class="{ isActive: isOpen }">
      <slot />
    </button>
    <div class="dropdown-list" v-if="isOpen">
    </div>
  </div>
</template>

<script>
export default {
  name: 'DropdownMenu',

  data() {
    return {
      isOpen: false,
    };
  },

  props: {
    campaignTypes: {
      type: Array,
      default: () => [],
    },
  },
  methods: {
    callToClose() {
      this.isOpen = false;
    },
  },
};
</script>

<style lang="scss" scoped>
  button {
    position: relative;
    padding: 10px 20px;
    background-color: white;
    border: 1px solid black;
    cursor: pointer;
    transition: 0.3s;
    &:focus {
      outline: 0px;
    }
    &:hover {
      background: #000;
      color: white;
    }
    &.isActive {
      background: #000;
      color: white;
    }
  }
  .dropdown {
    position: relative;
    width: fit-content;
    &-list {
      padding: 15px;
      background: white;
      margin-top: 5px;
      position: absolute;
      z-index: 10;
      border: 1px solid black;
      border-radius: 4px;
    }
  }
</style>