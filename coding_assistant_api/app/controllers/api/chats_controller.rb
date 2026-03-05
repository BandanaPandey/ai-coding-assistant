class Api::ChatsController < ApplicationController
  def create
    chat = ChatSession.create!(title: "New Chat")

    render json: chat
  end

  def message
    chat = ChatSession.find(params[:id])
    chat.messages.create!(role: "user", content: params[:message])

    ai_response = generate_ai_response(chat)
    chat.messages.create!(role: "assistant", content: ai_response)

    render json: { response: ai_response }
  end

  private

  def generate_ai_response(chat)
    context = build_context(chat)
    Llm::Client.new.generate(prompt: context)
  end

  def build_context(chat)
    history = chat.messages.last(10).map do |m|
      "#{m.role.upcase}: #{m.content}"
    end.join("\n")

    task_type = params[:task_type] || "explain"

    Llm::PromptBuilder.new(history, task_type).build
  end
end