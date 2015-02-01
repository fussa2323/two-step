#pragma once

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <map>
#include <climits>
#include <cfloat>
#include <cstdlib>

#include "confusion_set.h"

class confusion_network
{
private:
	
	int size;
public:
	std::vector<confusion_set> cn;
	void display();
	void push(confusion_set);
	int get_size();
	void clear();
	std::string best_hyp();				//����m���ő�̒P���I��
	std::string oracle_hyp();				//����m���ő�̒P���I��
	void labeling(std::vector<std::string>);			//DP�}�b�`���O�ɂ��e�P��ɐ���̃��x�����O���s��
	void output(std::ofstream&);						//���x���t��CN���t�@�C���ɏo��
	std::string most_correct_hyp(std::ofstream&);		//�����̒P���I��
	void out_perceptron_data(std::ofstream&);			//�p�[�Z�v�g�����̊w�K�p�̃f�[�^���o��
	void out_sem_perceptron_data(std::ofstream&);						//�Ӗ��X�R�A�t��CN���t�@�C���ɏo��
	void get_context(std::vector<std::string>&, std::map<std::string, int>);	//�R���e�L�X�g�P��̎擾
	void semantic_scoring(std::vector<std::string>, std::vector<double>, std::map<std::string, int>, std::vector<double>, std::vector<double *>);	//�Ӗ��X�R�A�̌v�Z
	void culc_weight(std::map<std::string,double>&, std::vector<std::vector<std::vector<int> > >);	//�d�݂̌v�Z
	void culc_score(std::map<std::string,double>&, std::vector<std::vector<std::vector<int> > >,double);	//�X�R�A���ő�̒P���I�����Ă���
public:
	confusion_network(void);
public:
	~confusion_network(void);
};

std::string get(int,int,int,int,std::vector<confusion_set>);
