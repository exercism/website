module EmailHelper
  def email_button_to(text, href)
    raw <<-BUTTON
    <table border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td align="center" style="border-radius: 5px;" bgcolor="#604FCD">
          <a class="button" href="#{href}" target="_blank" style="font-size: 20px;  color: #ffffff; text-decoration: none; color: #ffffff; text-decoration: none; padding: 15px 25px; border-radius: 5px; border: 1px solid #130B43; display: inline-block;">
            #{text}
          </a>
        </td>
      </tr>
    </table>
    BUTTON
  end
end
