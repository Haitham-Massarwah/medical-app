export function renderInvitationTemplate(data: { name: string; registrationUrl: string }) {
  const { name, registrationUrl } = data;
  return {
    text: `שלום ${name},\n\nהוזמנת להירשם לאפליקציית התורים.\nלהתחלת הרשמה: ${registrationUrl}\n\nתודה,\nMedical Appointments`,
    html: `
      <div style="font-family:Arial,sans-serif;line-height:1.6">
        <h2>שלום ${name},</h2>
        <p>הוזמנת להירשם לאפליקציית התורים.</p>
        <p>
          <a href="${registrationUrl}" style="background:#2563eb;color:#fff;padding:10px 16px;border-radius:6px;text-decoration:none;display:inline-block">התחלת הרשמה</a>
        </p>
        <p style="color:#6b7280">אם הכפתור לא עובד, העתק את הכתובת: <br/>${registrationUrl}</p>
        <hr/>
        <p>Medical Appointments</p>
      </div>
    `,
  };
}






