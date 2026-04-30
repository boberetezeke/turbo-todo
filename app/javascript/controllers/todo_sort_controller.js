import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  connect() {
    this.draggedItem = null
    this.dropTarget = null
    this.dropPosition = null
  }

  dragStart(event) {
      console.log("dragStart")
    this.draggedItem = event.currentTarget
    this.draggedItem.classList.add("dragging")

    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.draggedItem.dataset.todoId)
  }

  dragEnd() {
      console.log("dragEnd")
    if (this.draggedItem) {
      this.draggedItem.classList.remove("dragging")
    }

    this.clearDropMarkers()
    this.draggedItem = null
    this.dropTarget = null
    this.dropPosition = null
  }

  dragOver(event) {
    event.preventDefault()

    const candidate = event.currentTarget
    if (!this.draggedItem || candidate === this.draggedItem) {
      this.clearDropMarkers()
      this.dropTarget = null
      this.dropPosition = null
      return
    }

    const rect = candidate.getBoundingClientRect()
    const isBefore = event.clientY < rect.top + rect.height / 2

    this.clearDropMarkers()
    candidate.classList.add(isBefore ? "drop-before" : "drop-after")

    this.dropTarget = candidate
    this.dropPosition = isBefore ? "before" : "after"
  }

  async drop(event) {
      console.log("at beginning of drop 1")
    event.preventDefault()

      console.log("at beginning of drop")
    if (!this.draggedItem || !this.dropTarget) {
      return
    }

    const belowItem = this.dropPosition === "before" ? this.dropTarget : this.nextTodoItem(this.dropTarget)
    const targetOrder = belowItem ? Number.parseInt(belowItem.dataset.todoOrder, 10) : this.maxOrder() + 1

      console.log("belowItem=", belowItem);
      console.log("targetOrder=", targetOrder);
    if (!Number.isInteger(targetOrder) || targetOrder < 1) {
      return
    }

    const response = await fetch(this.draggedItem.dataset.updateUrl, {
      method: "PATCH",
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken()
      },
      body: JSON.stringify({ todo: { order: targetOrder } })
    })

    if (response.ok) {
      Turbo.renderStreamMessage(await response.text())
    }
   }

  nextTodoItem(todoItem) {
    let next = todoItem.nextElementSibling

    while (next && !next.dataset.todoId) {
      next = next.nextElementSibling
    }

    return next
  }

  maxOrder() {
    return Array.from(this.element.querySelectorAll("[data-todo-order]"))
      .map((item) => Number.parseInt(item.dataset.todoOrder, 10))
      .filter((value) => Number.isInteger(value))
      .reduce((max, value) => Math.max(max, value), 0)
  }

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }

  clearDropMarkers() {
    this.element.querySelectorAll(".drop-before, .drop-after").forEach((item) => {
      item.classList.remove("drop-before", "drop-after")
    })
  }
}

