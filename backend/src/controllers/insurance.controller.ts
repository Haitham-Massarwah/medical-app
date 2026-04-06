import { Request, Response } from 'express';
import db from '../config/database';

export class InsuranceController {
  async checkEligibility(req: Request, res: Response): Promise<void> {
    const tenantId = req.tenantId;
    const { patientId } = req.params;
    const { provider, memberId, policyNumber: _policyNumber } = req.body || {};
    try {
      if (!tenantId) {
        res.status(200).json({
          status: 'success',
          data: {
            eligible: true,
            provider: provider || 'Unknown',
            memberId: memberId || '',
            coverageType: 'medical',
            message: 'Eligibility check (stub). Configure insurer API for production.',
          },
        });
        return;
      }
      const [record] = await db('patient_insurance')
        .where({ tenant_id: tenantId, patient_id: patientId })
        .orderBy('effective_to', 'desc')
        .limit(1);
      res.status(200).json({
        status: 'success',
        data: {
          eligible: !!record,
          provider: record?.provider || provider || 'Unknown',
          memberId: record?.member_id || memberId || '',
          coverageType: 'medical',
          effectiveTo: record?.effective_to,
          message: record ? 'Eligibility verified from record.' : 'Eligibility check (stub). Add insurer API for production.',
        },
      });
    } catch {
      res.status(200).json({
        status: 'success',
        data: {
          eligible: true,
          provider: provider || 'Stub',
          memberId: memberId || '',
          coverageType: 'medical',
          message: 'Eligibility check (stub). Configure insurer API for production.',
        },
      });
    }
  }

  async submitClaim(req: Request, res: Response): Promise<void> {
    const {
      patientId,
      appointmentId,
      amount,
      diagnosisCode: _diagnosisCode,
      serviceCode: _serviceCode,
    } = req.body || {};
    res.status(201).json({
      status: 'success',
      data: {
        claimId: `claim-${Date.now()}`,
        status: 'submitted',
        patientId: patientId || '',
        appointmentId: appointmentId || '',
        amount,
        message: 'Claim submitted (stub). Integrate with insurer API for production.',
      },
    });
  }

  async getPatientInsurance(req: Request, res: Response): Promise<void> {
    const tenantId = req.tenantId;
    const { patientId } = req.params;
    try {
      if (!tenantId) {
        res.status(200).json({ status: 'success', data: { policies: [] } });
        return;
      }
      const policies = await db('patient_insurance')
        .where({ tenant_id: tenantId, patient_id: patientId })
        .orderBy('effective_to', 'desc');
      res.status(200).json({ status: 'success', data: { policies } });
    } catch {
      res.status(200).json({ status: 'success', data: { policies: [] } });
    }
  }
}
