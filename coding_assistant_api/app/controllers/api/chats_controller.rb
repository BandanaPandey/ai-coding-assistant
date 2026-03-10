# app/controllers/api/chats_controller.rb
class Api::ChatsController < ApplicationController
  def create
    chat = ChatSession.create!(title: "New Chat")
    render json: chat
  end

  def message
    chat = ChatSession.find(params[:id])

    user_payload = {
      code: params[:code],
      task_type: params[:task_type],
      file_path: params[:file_path],
      repo_path: params[:repo_path],
      language: params[:language],
      surrounding_code: params[:surrounding_code]
    }

    chat.messages.create!(
      role: "user",
      content: user_payload.to_json
    )

    ai_response = generate_ai_response(chat, user_payload)

    chat.messages.create!(
      role: "assistant",
      content: ai_response
    )

    render json: { response: ai_response }
  end

  private

  def generate_ai_response(chat, payload)

    rag_context = retrieve_repo_context(payload)

    prompt = build_prompt(
      chat: chat,
      payload: payload,
      rag_context: rag_context
    )

    Llm::Client.new.generate(prompt: prompt)
  end

  def build_prompt(chat:, payload:, rag_context:)

    history = chat.messages.last(10).map do |m|
      "#{m.role.upcase}: #{m.content}"
    end.join("\n")

    context = {
      history: history,
      code: payload[:code],
      surrounding_code: payload[:surrounding_code],
      file_path: payload[:file_path],
      language: payload[:language],
      rag_context: rag_context
    }

    Llm::PromptBuilder.new(context, payload[:task_type]).build
  end

  def retrieve_repo_context(payload)

    query = [
      payload[:code],
      payload[:surrounding_code]
    ].join("\n")

    Rag::Retriever.search(query)
  end

end